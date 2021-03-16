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
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
		
		// display the actual button-states on initialising
		for (devName, devObj) in hmDevices {
			if (devObj.hmType == "actor" && devObj.olName != "") {
				if let buttonOl = value(forKey: devObj.olName) as? NSButton {
					displayHMStateOnBtn(buttonOl, hmDevices[devName]!)
				}
			}
		}
	}
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	/*** HM-buttons */
	@IBOutlet weak var btnEsstisch: NSButton!
	@IBAction func btnEsstisch(_ sender: NSButton) {
		let btnClss = hmDevices["Esstischlicht"]!
		
		setBreakIntervall(btnEsstisch, btnClss)
		
		// toggle state of according HM-device
		btnClss.toggleState()
	}
	
	@IBOutlet weak var btnArtischocke: NSButton!
	@IBAction func btnArtischocke(_ sender: NSButton) {
		let btnClss = hmDevices["Artischocke"]!
		
		setBreakIntervall(btnArtischocke, btnClss)
		
		// toggle state of according HM-device
		btnClss.toggleState()
	}
	
	@IBOutlet weak var btnTVLicht: NSButton!
	@IBAction func btnTVLicht(_ sender: NSButton) {
		let btnClss = hmDevices["TV-Licht"]!
		
		setBreakIntervall(btnTVLicht, btnClss)
		
		// toggle state of according HM-device
		btnClss.toggleState()
	}
	
	// wait after button-press for defined time, to let HM-devices get "ready" (ramptime etc.)
	func setBreakIntervall(_ btnTrgt: NSButton, _ reqDev: hmDevice) {
		// disable button for defined break-intervall
		btnTrgt.isEnabled = false
		Timer.scheduledTimer(withTimeInterval: Double(reqDev.breakSec), repeats: false) { timer in
			btnTrgt.isEnabled = true
			self.displayHMStateOnBtn(btnTrgt, reqDev)
		}
	}
	
	func displayHMStateOnBtn(_ btnTrgt: NSButton, _ reqDev: hmDevice) {
		/*let btnColorOff = NSColor.white.cgColor
		let btnColorOn  = NSColor.red.cgColor*/
		print("TEst: device: \(String(describing: reqDev.indexName())) | offOn: \(reqDev.deviceIsOn()) | State: \(String(describing: reqDev.state))")
		if (reqDev.deviceIsOn()) {
			btnTrgt.image = NSImage(named:"btn_\(reqDev.iconType)_on")
			//btnTrgt.layer?.backgroundColor = btnColorOn
		} else {
			btnTrgt.image = NSImage(named:"btn_\(reqDev.iconType)_off")
			//btnTrgt.layer?.backgroundColor = btnColorOff
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
