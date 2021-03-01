//
//  HMControl.swift
//  HMControl
//
//  Created by Georg Kemser on 26.02.21.
//

import Cocoa
import Foundation

// HM-devices instantiation
let hmDevices = hmDevice.definition

class hmDevice {
	let iseId: Int
	let minVal: Float
	let maxVal: Float
	let breakSec: Int // some devices need some time, till they can "react" again (because of ramp-time etc.)
	var state: Float?
	
	init(iseId: Int, minVal: Float, maxVal: Float, breakSec: Int, state: Float?) {
		self.iseId = iseId
		self.minVal = minVal
		self.maxVal = maxVal
		self.breakSec = breakSec
		self.getState() // -1 = "state could not be determined"
	}
	
	// inital definition of all HM-device, that should be controled via app
	static let definition: [String: hmDevice] =  [
		"Artischocke":     hmDevice(iseId: 1687,  minVal: 0.0, maxVal: 1.0, breakSec: 1, state: -1.0),
		"Sofa Leselicht":  hmDevice(iseId: 2060,  minVal: 0.0, maxVal: 1.0, breakSec: 1, state: -1.0),
		"Esstischlicht":   hmDevice(iseId: 56153, minVal: 0.0, maxVal: 0.1, breakSec: 3, state: -1.0),
		"Drucker":         hmDevice(iseId: 52613, minVal: 0.0, maxVal: 1.0, breakSec: 3, state: -1.0),
		"TV-Licht":        hmDevice(iseId: 33309, minVal: 0.0, maxVal: 1.0, breakSec: 5, state: -1.0)
	]
	
	// all states (statelist)
	//http://10.10.10.90/config/xmlapi/statelist.cgi
	func getState() {
		let getURL = "http://10.10.10.90/config/xmlapi/state.cgi"
		
		// call CCU3 via http GET-method
		Utils.readXMLViaHTTPGetRequest(_:self, location: "\(getURL)?datapoint_id=\(self.iseId)")
	}
	
	func setState(newValue: Float) {
		let setURL = "http://10.10.10.90/addons/xmlapi/statechange.cgi"
		
		var newValueString = "0"
		// make sure, int-values ar given as int and float-values as float
		newValueString = (floor(newValue) == newValue) ? String(Int(newValue)) : String(newValue)
		
		// call CCU3 via http GET-method (asynchronous, do not care about return-data)
		Utils.doAsyncHTTPGetRequest(location: "\(setURL)?ise_id=\(iseId)&new_value=\(newValueString)")
	}
	
	func toggleState() {
		self.getState()
		
		let newValueString:Float = (self.state! > 0) ? 0.0 : 1.0
		print("hmDevicesState \(self.iseId): \(String(describing: self.state!)) | newValue: \(newValueString)")
		
		self.setState(newValue: newValueString)
	}
	
	func deviceIsOn() -> Bool {
		if (self.state! > 0) { return true } else { return false }
	}
}
