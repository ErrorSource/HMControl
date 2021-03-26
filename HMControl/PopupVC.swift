//
//  PopupVC.swift
//  HMControl
//
//  Created by Georg Kemser on 25.02.21.
//

import Cocoa

class PopupVC: NSViewController {
	
	let backgroundQueue = DispatchQueue(label: "dataSyncQueue", attributes: .concurrent)
	// have to wait for async-job to be finished
	let dsptchGrp = DispatchGroup()
	// completion-handler-helper
	typealias finishedCreatingIBElements = () -> ()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// dynamically create elements defined in HMDevices list
		createIBElements() { () -> () in
			print("createIBElements completed!")
		}
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
		
		// buttons-stackview (first grouped stackview) has a margin of 40px from top; use this also at bottom; plus spacing of 40px between
		let margins: Int = (40 * 3)
		// calculate the overall height of top-stackviews + margin
		let ovrllHght: Int = (self.getSVsOverallHeight() + margins)
		// set ViewControllers height to it
		self.view.heightAnchor.constraint(equalToConstant: CGFloat(ovrllHght)).isActive = true
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		// read and parse statelist via CCU-xmlapi and adjust according NSElements (buttons, sliders, labels...)
		refreshHMStateList()
	}
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
			
		}
	}
	
	// create views --------------------------------------------------------
	func createIBElements(completed: finishedCreatingIBElements) {
		var svBtnGrp = [Int: [NSButton]]()
		var svThrmGrp = [Int: [NSStackView]]()
		var svThrmGrpName = [Int: String]()
		
		let sorted_hmDevices = hmDevices.sorted(by: {
			(hmDevices[$0.key]!.btnGrp, hmDevices[$0.key]!.orderId) < (hmDevices[$1.key]!.btnGrp, hmDevices[$1.key]!.orderId)
		})
		
		// iterate through hmDevices and sort them into according stackview-"groups"
		for (devName, devObj) in sorted_hmDevices {
			// create actor-buttons (toggle)
			if (devObj.hmType == "actor" && devObj.btnGrp != 0) {
				let hmBtn = createHMToggleButton(devName: devName, devObj: devObj)
				
				// add button to button-group (within dictionary)
				// (there is only place for 4 buttons; do not process more)
				if (devObj.orderId <= 4) {
					//btnGrp.append(hmBtn)
					if var btnGrp = svBtnGrp[devObj.btnGrp] {
						btnGrp.append(hmBtn)
						svBtnGrp[devObj.btnGrp] = btnGrp
					} else {
						svBtnGrp[devObj.btnGrp] = [hmBtn]
					}
				}
			}
			// create thermostat-groups (each a stackview)
			if (devObj.hmType == "thermostat") {
				let hmThrmSldr = createHMThrmSliderSV(devName: devName, devObj: devObj)
				
				// add thermostate-group to stackview-group (within dictionary)
				if var thrmGrp = svThrmGrp[devObj.orderId] {
					thrmGrp.append(hmThrmSldr)
					svThrmGrp[devObj.orderId] = thrmGrp
					svThrmGrpName[devObj.orderId] = devName
				} else {
					svThrmGrp[devObj.orderId] = [hmThrmSldr]
					svThrmGrpName[devObj.orderId] = devName
				}
			}
		}
		
		// create parent-buttons-stackview (vertical)
		let hmBntPrntSV = createHMBtnParentStackview()
		// add parent-buttons-stackview to main view
		self.view.addSubview(hmBntPrntSV)
		
		// create parent-thermostat-stackview (vertical)
		let hmThrmSldrPrntSV = createHMThrmSldrParentStackview()
		// add parent-buttons-stackview to main view
		self.view.addSubview(hmThrmSldrPrntSV)
		
		// create sub-stackview(s) and add button-group(s)
		for (_, btnGrpObj) in svBtnGrp.sorted(by: { $0.0 < $1.0 }) {
			let hmBtnGrpSV = createHMBtnGrpStackview(btnGrpObj: btnGrpObj)
			// add subviews to parent-stackview
			hmBntPrntSV.addArrangedSubview(hmBtnGrpSV)
		}
		
		// create sub-stackview(s) and add thermostat-group(s)
		for (thrmGrpId, thrmGrpSV) in svThrmGrp.sorted(by: { $0.0 < $1.0 }) {
			// add label on top of thermostate-group (inside parent-stackview)
			let hmThrmGrpLbl = createHMThrmGrpLabel(devName: svThrmGrpName[thrmGrpId]!)
			hmThrmSldrPrntSV.addArrangedSubview(hmThrmGrpLbl)
			
			let hmThrmGrpSV = createHMThrmGrpStackview(thrmGrpSV: thrmGrpSV)
			// add subviews to parent-stackview
			hmThrmSldrPrntSV.addArrangedSubview(hmThrmGrpSV)
			// constraints for sub-stackview
			constrainsHMThrmSldrGrpStackview(hmThrmSldrGrpSV: hmThrmGrpSV, subView: hmThrmSldrPrntSV)
		}
		
		// constraints for parent-stackview
		constrainsHMBtnParentStackview(hmBntPrntSV: hmBntPrntSV, popupView: self.view)
		
		// constraints for parent-thermostat-stackview
		constrainsHMThrmSldrParentStackview(hmThrmSldrPrntSV: hmThrmSldrPrntSV, hmBntPrntSV: hmBntPrntSV, popupView: self.view)
		
		// return "signal" for completion-handler
		completed()
	}
	// end create views ----------------------------------------------------
	
	@objc func hmBtnActionToggle(_ sender: NSButton) {
		setActionBreakIntervall(sender, hmDevices[sender.title]!)
		
		// toggle state of according HM-device
		hmDevices[sender.title]!.toggleState()
	}
	
	@objc func hmSldrThermAction(_ sender: NSSlider) {
		// get parent-object thermostat
		let prntIseId = sender.objIdntfr!.capturedGroups(withRegex: "^([0-9]*)_")[0] // take first matched group of array; there should be only one
		
		// update soll-lbl on every change
		let trgtViewLbl = getViewElementByObjIdntfr(objIdntfr: "\(prntIseId)_sollLbl")! as NSView
		guard let sollLbl = trgtViewLbl as? NSTextField else { return }
		
		sollLbl.stringValue = sender.stringValue.temperatureString
		sollLbl.textColor = (sollLbl.objStoredVal! != sender.stringValue.temperatureString) ? NSColor.red : NSColor.white
		
		// perform statechange only, if slider-position changed (not the same value as before) and after mouse-button was released
		let event = NSApplication.shared.currentEvent
		if (event?.type == NSEvent.EventType.leftMouseUp) {
			for (_, devObj) in hmDevices {
				if (devObj.iseId == Int(prntIseId)! && devObj.state != sender.floatValue) {
					setActionBreakIntervall(sender, hmDevices[devObj.indexName()]!)
					
					sollLbl.textColor = NSColor.white
					hmDevices[devObj.indexName()]!.setState(newValue: sender.floatValue)
				}
			}
		}
	}
	
	@objc func hmCtrlBtnThermAction(_ sender: NSButton) {
		// get parent-object thermostat
		let prntIseId = sender.objIdntfr!.capturedGroups(withRegex: "^([0-9]*)_")[0] // take first matched group of array; there should be only one
		
		for (_, devObj) in hmDevices {
			if (devObj.iseId == Int(prntIseId)! && devObj.state != sender.floatValue) {
				setActionBreakIntervall(sender, hmDevices[devObj.indexName()]!)
				
				hmDevices[devObj.indexName()]!.triggerThermMode(mode: sender.objStoredVal!)
				hmDevices[devObj.indexName()]!.getState()
				setHMTempPosOnSldr(devObj: hmDevices[devObj.indexName()]!)
			}
		}
	}
	
	func refreshHMStateList() {
		// read statelist only every 5sec minimum
		let refreshMargin = 5
		
		if (hmDevList.lastReadingUTC <= 1609459200 || hmDevList.lastReadingUTC + Double(refreshMargin) < NSDate().timeIntervalSince1970) {
			// initiate reading and parsing of statelist via CCU-xmlapi
			// will take some time! (asynchronous task)
			dsptchGrp.enter()
			backgroundQueue.async {
				hmDevList.startXMLReading { res in
					// refresh object-state from statelist
					for (_, devObj) in hmDevices {
						devObj.getStateFromStateList()
					}
					hmDevList.initialReadingDone = true
					
					self.dsptchGrp.leave()
				}
			}
		}
		
		// use an asynchronous main-task to not block showup of popup
		// (outlets can only be accessed from within main-task!)
		DispatchQueue.main.async {
			// wait, till asynchronous background-task is finished, but - like describe above - in an other asynchronous main-task
			self.dsptchGrp.wait()
			// now, lets map according device-values to buttons and labels
			if (hmDevList.initialReadingDone == true) {
				self.mapStatesToDevices()
			}
		}
	}
	
	@objc func mapStatesToDevices() {
		
		for (devName, devObj) in hmDevices {
			// display the actual button-states on initialising
			if (devObj.hmType == "actor") {
				DispatchQueue.main.async {
					self.displayHMStateOnBtn(devObj: devObj)
				}
			}
			
			// set corresponding slider-position and labels of thermostats
			if (devObj.hmType == "thermostat") {
				DispatchQueue.main.async {
					self.setHMTempPosOnSldr(devObj: devObj)
					self.setHMTempValueOnGauge(devObj: devObj)
				
					// initially assign the image of comfort-, lowering-, boost-button
					for trgtMode in ["Comfort", "Lowering", "Boost"] {
						let trgtView = self.getViewElementByObjIdntfr(objIdntfr: "\(devObj.iseId)_\(trgtMode)Btn")! as NSView
						guard let hmModeBtn = trgtView as? NSButton else { return }
						hmModeBtn.image = NSImage(named:"btn_\(hmDevices[devName]!.iconType)_\(trgtMode.lowercased())")!.resizedCopy(w: 20.0, h:20.0)
					}
				}
			}
		}
	}
	
	func displayHMStateOnBtn(devObj: hmDevice) {
		let trgtView = getViewElementByObjIdntfr(objIdntfr: "\(devObj.iseId)_tgglBtn")! as NSView
		guard let hmBtn = trgtView as? NSButton else { return }
		let hmBtnState: String = (devObj.deviceIsOn()) ? "on" : "off"
		hmBtn.image = NSImage(named:"btn_\(devObj.iconType)_\(hmBtnState)")!.resizedCopy(w: 40.0, h:40.0)
	}
	
	func setHMTempPosOnSldr(devObj: hmDevice) {
		let trgtViewSldr = getViewElementByObjIdntfr(objIdntfr: "\(devObj.iseId)_sollSldr")! as NSView
		let trgtViewLbl = getViewElementByObjIdntfr(objIdntfr: "\(devObj.iseId)_sollLbl")! as NSView
		guard let sollSldr = trgtViewSldr as? NSSlider else { return }
		guard let sollLbl = trgtViewLbl as? NSTextField else { return }
		
		sollSldr.floatValue = devObj.state ?? 19.0
		sollLbl.stringValue = String(devObj.state!).temperatureString
	}
	
	func setHMTempValueOnGauge(devObj: hmDevice) {
		let trgtView = getViewElementByObjIdntfr(objIdntfr: "\(devObj.iseId)_istLbl")! as NSView
		guard let txtFld = trgtView as? NSTextField else { return }
		// get actual determined temperatur of hmdevice from statelist and set it on devices "ist-label"
		txtFld.stringValue = String(devObj.getThermActValue()).temperatureString
	}
	
	// wait after button-press for defined time, to let HM-devices get "ready" (ramptime etc.)
	func setActionBreakIntervall(_ actnTrgt: Any, _ reqDev: hmDevice) {
		if let btnTrgt = actnTrgt as? NSButton {
			// disable button for defined break-intervall
			btnTrgt.isEnabled = false
			Timer.scheduledTimer(withTimeInterval: Double(reqDev.breakSec), repeats: false) { timer in
				btnTrgt.isEnabled = true
				self.displayHMStateOnBtn(devObj: reqDev)
			}
		}
		if let sldrTrgt = actnTrgt as? NSSlider {
			// disable button for defined break-intervall
			sldrTrgt.isEnabled = false
			Timer.scheduledTimer(withTimeInterval: Double(reqDev.breakSec), repeats: false) { timer in
				sldrTrgt.isEnabled = true
				self.setHMTempPosOnSldr(devObj: reqDev)
			}
		}
	}
}

extension PopupVC {
	// Storyboard instantiation
	static func freshController() -> PopupVC {
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let identifier = NSStoryboard.SceneIdentifier("PopupVC")
		guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? PopupVC else {
			fatalError("Can't find viewController 'PopupVC'! Check Main.storyboard...")
		}
		return viewController
	}
}
