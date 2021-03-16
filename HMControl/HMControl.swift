//
//  HMControl.swift
//  HMControl
//
//  Created by Georg Kemser on 26.02.21.
//

import Cocoa
import Foundation

// HM-devices instantiation
let hmDevices =  hmDevice.definition

class hmDevice {
	// breakSec: some devices need some time, till they can "react" again (because of ramp-time etc.)
	let iseId: Int, hmType: String, olName: String, iconType: String, minVal: Float, maxVal: Float, breakSec: Int
	var state: Float?
	
	init(iseId: Int, hmType: String, olName: String, iconType: String, minVal: Float, maxVal: Float, breakSec: Int, state: Float?) {
		self.iseId = iseId
		self.hmType = hmType
		self.olName = olName
		self.iconType = iconType
		self.minVal = minVal
		self.maxVal = maxVal
		self.breakSec = breakSec
		self.getState() // -1 = "state could not be determined"
	}
	
	// definition of HM-devices is done on HMDevices.swift
	
	// all states (statelist)
	//http://10.10.10.90/config/xmlapi/statelist.cgi
	func getState() {
		let getURL = "http://10.10.10.90/config/xmlapi/state.cgi"
		
		// call CCU3 via http GET-method
		Utils.readXMLViaHTTPGetRequest(_: self, location: "\(getURL)?datapoint_id=\(self.iseId)")
	}
	
	func setState(newValue: Float) {
		let setURL = "http://10.10.10.90/addons/xmlapi/statechange.cgi"
		
		var newValueString = "0"
		// make sure, int-values ar given as int and float-values as float
		newValueString = (floor(newValue) == newValue) ? String(Int(newValue)) : String(newValue)
		
		// call CCU3 via http GET-method
		Utils.setHMStateViaHTTPGetRequest(_: self, location: "\(setURL)?ise_id=\(iseId)&new_value=\(newValueString)")
	}
	
	func toggleState() {
		let newValueString:Float = (self.state! > 0) ? 0.0 : self.maxVal
		self.setState(newValue: newValueString)
	}
	
	func deviceIsOn() -> Bool {
		if (self.state! > 0) { return true } else { return false }
	}
}

extension hmDevice {
	func indexName() -> String {
		let key = hmDevices
			.filter { (key, attr) -> Bool in attr.iseId == self.iseId }
			.map { (key, attr) -> String in key }[0]
		if (key != "") { return key } else { return "" }
	}
}
