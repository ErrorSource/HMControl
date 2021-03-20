//
//  PopupVC.swift
//  HMControl
//
//  Created by Georg Kemser on 25.02.21.
//

import Cocoa

class PopupVC: NSViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let dsptchGrp = DispatchGroup()
		dsptchGrp.enter()
		DispatchQueue.global(qos: .default).async {
			// initiate reading and parsing of statelist via CCU-xmlapi
			// will take some time! (asynchronous task)
			hmDevList.startInitialReading { res in
				hmDevList.initialReadingDone = true
				dsptchGrp.leave()
			}
		}
		
		// wait, till asynchronous-task is done
		dsptchGrp.wait()
		
		setInitialStates()
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
		
	}
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	//*** HM-buttons ***
	@IBOutlet weak var btnEsstisch: NSButton!
	@IBAction func btnEsstisch(_ sender: NSButton) {
		setBreakIntervall(btnEsstisch!, hmDevices["Esstischlicht"]!)
		
		// toggle state of according HM-device
		hmDevices["Esstischlicht"]!.toggleState()
	}
	
	@IBOutlet weak var btnArtischocke: NSButton!
	@IBAction func btnArtischocke(_ sender: NSButton) {
		setBreakIntervall(btnArtischocke!, hmDevices["Artischocke"]!)
		
		// toggle state of according HM-device
		hmDevices["Artischocke"]!.toggleState()
	}
	
	@IBOutlet weak var btnTVLicht: NSButton!
	@IBAction func btnTVLicht(_ sender: NSButton) {
		setBreakIntervall(btnTVLicht!, hmDevices["TV-Licht"]!)
		
		// toggle state of according HM-device
		hmDevices["TV-Licht"]!.toggleState()
	}
	
	//*** HM-sliders ***
	//--- Wohnzimmer ---
	@IBOutlet weak var lblIstWohnzimmer: NSTextField!
	@IBOutlet weak var lblSollWohnzimmer: NSTextField!
	@IBOutlet weak var sldrWohnzimmer: NSSlider!
	@IBAction func sldrWohnzimmer(_ sender: NSSlider) {
		setBreakIntervall(sldrWohnzimmer!, hmDevices["Wohnzimmer"]!)

		// get value from slider and set target temperature of according HM-device
		hmDevices["Wohnzimmer"]!.setState(newValue: sldrWohnzimmer.floatValue)
		lblSollWohnzimmer.stringValue = "\(String(sldrWohnzimmer.floatValue))°C"
	}
	// comfort-, lowering-, boost-button
	@IBOutlet weak var btnWohnzimmerComfort: NSButton!
	@IBAction func btnWohnzimmerComfort(_ sender: NSButton) {
		hmDevices["Wohnzimmer"]!.triggerThermMode(mode: "Comfort", olName: "btnWohnzimmerComfort")
		hmDevices["Wohnzimmer"]!.getState()
		setHMTempPosOnSldr(sldrTrgtOl: "sldrWohnzimmer", lblTrgtOl: "lblSollWohnzimmer", hmDevices["Wohnzimmer"]!)
	}
	@IBOutlet weak var btnWohnzimmerLowering: NSButton!
	@IBAction func btnWohnzimmerLowering(_ sender: NSButton) {
		hmDevices["Wohnzimmer"]!.triggerThermMode(mode: "Lowering", olName: "btnWohnzimmerLowering")
		hmDevices["Wohnzimmer"]!.getState()
		setHMTempPosOnSldr(sldrTrgtOl: "sldrWohnzimmer", lblTrgtOl: "lblSollWohnzimmer", hmDevices["Wohnzimmer"]!)
	}
	@IBOutlet weak var btnWohnzimmerBoost: NSButton!
	@IBAction func btnWohnzimmerBoost(_ sender: NSButton) {
		hmDevices["Wohnzimmer"]!.triggerThermMode(mode: "Boost", olName: "btnWohnzimmerBoost")
		// display boost-mode via button for 600secs long?
	}
	//--- End Wohnzimmer ---
	
	//--- Galerie ---
	@IBOutlet weak var lblIstGalerie: NSTextField!
	@IBOutlet weak var lblSollGalerie: NSTextField!
	@IBOutlet weak var sldrGalerie: NSSlider!
	@IBAction func sldrGalerie(_ sender: NSSlider) {
		setBreakIntervall(sldrGalerie!, hmDevices["Galerie"]!)

		// get value from slider and set target temperature of according HM-device
		hmDevices["Galerie"]!.setState(newValue: sldrGalerie.floatValue)
		lblSollGalerie.stringValue = "\(String(sldrGalerie.floatValue))°C"
	}
	// comfort-, lowering-, boost-button
	@IBOutlet weak var btnGalerieComfort: NSButton!
	@IBAction func btnGalerieComfort(_ sender: NSButton) {
		hmDevices["Galerie"]!.triggerThermMode(mode: "Comfort", olName: "btnGalerieComfort")
		hmDevices["Galerie"]!.getState()
		setHMTempPosOnSldr(sldrTrgtOl: "sldrGalerie", lblTrgtOl: "lblSollGalerie", hmDevices["Galerie"]!)
	}
	@IBOutlet weak var btnGalerieLowering: NSButton!
	@IBAction func btnGalerieLowering(_ sender: NSButton) {
		hmDevices["Galerie"]!.triggerThermMode(mode: "Lowering", olName: "btnGalerieLowering")
		hmDevices["Galerie"]!.getState()
		setHMTempPosOnSldr(sldrTrgtOl: "sldrGalerie", lblTrgtOl: "lblSollGalerie", hmDevices["Galerie"]!)
	}
	@IBOutlet weak var btnGalerieBoost: NSButton!
	@IBAction func btnGalerieBoost(_ sender: NSButton) {
		hmDevices["Galerie"]!.triggerThermMode(mode: "Boost", olName: "btnGalerieBoost")
		// display boost-mode via button for 600secs long?
	}
	//--- End Galerie ---
	
	//--- Bad ---
	@IBOutlet weak var lblIstBad: NSTextField!
	@IBOutlet weak var lblSollBad: NSTextField!
	@IBOutlet weak var sldrBad: NSSlider!
	@IBAction func sldrBad(_ sender: NSSlider) {
		setBreakIntervall(sldrBad!, hmDevices["Bad"]!)

		// get value from slider and set target temperature of according HM-device
		hmDevices["Bad"]!.setState(newValue: sldrBad.floatValue)
		lblSollBad.stringValue = "\(String(sldrBad.floatValue))°C"
	}
	// comfort-, lowering-, boost-button
	@IBOutlet weak var btnBadComfort: NSButton!
	@IBAction func btnBadComfort(_ sender: NSButton) {
		hmDevices["Bad"]!.triggerThermMode(mode: "Comfort", olName: "btnBadComfort")
		hmDevices["Bad"]!.getState()
		setHMTempPosOnSldr(sldrTrgtOl: "sldrBad", lblTrgtOl: "lblSollBad", hmDevices["Bad"]!)
	}
	@IBOutlet weak var btnBadLowering: NSButton!
	@IBAction func btnBadLowering(_ sender: NSButton) {
		hmDevices["Bad"]!.triggerThermMode(mode: "Lowering", olName: "btnBadLowering")
		hmDevices["Bad"]!.getState()
		setHMTempPosOnSldr(sldrTrgtOl: "sldrBad", lblTrgtOl: "lblSollBad", hmDevices["Bad"]!)
	}
	@IBOutlet weak var btnBadBoost: NSButton!
	@IBAction func btnBadBoost(_ sender: NSButton) {
		hmDevices["Bad"]!.triggerThermMode(mode: "Boost", olName: "btnBadBoost")
		// display boost-mode via button for 600secs long?
	}
	//--- End Bad ---
	
	func setInitialStates() {
		for (devName, devObj) in hmDevices {
			// display the actual button-states on initialising
			if (devObj.hmType == "actor" && devObj.olName != "") {
				if let buttonOl = value(forKey: devObj.olName) as? NSButton {
					displayHMStateOnBtn(buttonOl, hmDevices[devName]!)
				}
			}
			
			// set corresponding slider-position and labels of thermostats
			if (devObj.hmType == "thermostat" && devObj.olName != "") {
				DispatchQueue.main.async {
					print(hmDevList.initialReadingDone)
					self.setHMTempPosOnSldr(sldrTrgtOl: "sldr\(devName)", lblTrgtOl: "lblSoll\(devName)", hmDevices[devName]!)
					self.setHMTempValueOnGauge(ggTrgtOl: "lblIst\(devName)", hmDevices[devName]!)
				}
				
				// initially assign the image of comfort-, lowering-, boost-button
				for trgtMode in ["Comfort", "Lowering", "Boost"] {
					if let btnComfort = value(forKey: "btn\(hmDevices[devName]!.indexName())\(trgtMode)") as? NSButton {
						btnComfort.image = NSImage(named:"btn_\(hmDevices[devName]!.iconType)_\(trgtMode.lowercased())")!.resizedCopy(w: 20.0, h:20.0)
					}
				}
			}
		}
	}
	
	// wait after button-press for defined time, to let HM-devices get "ready" (ramptime etc.)
	func setBreakIntervall(_ actnTrgt: Any, _ reqDev: hmDevice) {
		if let btnTrgt = actnTrgt as? NSButton {
			// disable button for defined break-intervall
			btnTrgt.isEnabled = false
			Timer.scheduledTimer(withTimeInterval: Double(reqDev.breakSec), repeats: false) { timer in
				btnTrgt.isEnabled = true
				self.displayHMStateOnBtn(btnTrgt, reqDev)
			}
		}
		if let sldrTrgt = actnTrgt as? NSSlider {
			// disable button for defined break-intervall
			sldrTrgt.isEnabled = false
			Timer.scheduledTimer(withTimeInterval: Double(reqDev.breakSec), repeats: false) { timer in
				sldrTrgt.isEnabled = true
				//self.displayHMStateOnBtn(btnTrgt, reqDev)
			}
		}
	}
	
	func displayHMStateOnBtn(_ btnTrgt: NSButton, _ reqDev: hmDevice) {
		/*let btnColorOff = NSColor.white.cgColor
		let btnColorOn  = NSColor.red.cgColor*/
		//print("displayHMStateOnBtn: device: \(String(describing: reqDev.indexName())) | offOn: \(reqDev.deviceIsOn()) | State: \(String(describing: reqDev.state))")
		if (reqDev.deviceIsOn()) {
			btnTrgt.image = NSImage(named:"btn_\(reqDev.iconType)_on")!.resizedCopy(w: 50.0, h:50.0)
			//btnTrgt.layer?.backgroundColor = btnColorOn
		} else {
			btnTrgt.image = NSImage(named:"btn_\(reqDev.iconType)_off")!.resizedCopy(w: 50.0, h:50.0)
			//btnTrgt.layer?.backgroundColor = btnColorOff
		}
	}
	
	func setHMTempPosOnSldr(sldrTrgtOl sldrTrgt: String, lblTrgtOl lblTrgt: String, _ reqDev: hmDevice) {
		guard let sldrOl = value(forKey: sldrTrgt) as? NSSlider else { return }
		guard let lblOl = value(forKey: lblTrgt) as? NSTextField else { return }
		
		//print("setHMTempPosOnSldr: device: \(String(describing: reqDev.indexName())) | State: \(String(describing: reqDev.state))")
		sldrOl.floatValue = reqDev.state ?? 19.0
		lblOl.stringValue = "\(String(reqDev.state ?? 12.0))°C"
	}
	
	func setHMTempValueOnGauge(ggTrgtOl ggTrgt: String, _ reqDev: hmDevice) {
		guard let ggOl = value(forKey: ggTrgt) as? NSTextField else { return }
		
		reqDev.getThermActValue(olName: ggTrgt, olTrgt: ggOl)
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
