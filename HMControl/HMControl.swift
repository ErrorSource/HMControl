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

// define helper variable for creating virtual/dynamic (sub-)devices
var dynamicHmDevs : [hmDevice] = []

class hmDevice {
	let iseId: Int, hmType: String, btnGrp: Int, orderId: Int, iconType: String, minVal: Float, maxVal: Float, breakSec: Int
	var state: Float?
	
	init(iseId: Int, hmType: String, btnGrp: Int = 0, orderId: Int = 0, iconType: String, minVal: Float = 0.0, maxVal: Float = 1.0, breakSec: Int = 1, state: Float? = -1.0) {
		self.iseId = iseId
		self.hmType = hmType
		self.btnGrp = btnGrp
		self.orderId = orderId
		self.iconType = iconType
		self.minVal = minVal
		self.maxVal = maxVal
		self.breakSec = breakSec
		self.getState()
	}
	
	// definition of HM-devices is done on HMDevices.swift
	func getState() {
		let getURL = "http://10.10.10.90/config/xmlapi/state.cgi"
		
		// call CCU3 via http GET-method
		Utils.readXMLViaHTTPGetRequest(_: self, location: "\(getURL)?datapoint_id=\(self.iseId)")
	}
	
	func getStateFromStateList() {
		let dtPtValue = hmDevList.getDtPtValue(searchId: hmDevices[self.indexName()]!.iseId)
		
		self.state = (dtPtValue != -1.0) ? dtPtValue : -1.0
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
	
	func getThermActValue() -> Float {
		let actualTempId = hmDevList.getThermDtPtViaIseId(searchId: hmDevices[self.indexName()]!.iseId, searchMode: "ACTUAL_TEMPERATURE")
		if (actualTempId != -1) {
			var actualTempDev: hmDevice
			// already created?
			if let foundDev = dynamicHmDevs.first(where: {$0.iseId == actualTempId}) {
				// reference to the former created virtual (sub-)device
				actualTempDev = foundDev
			} else {
				// create virtual (sub-)device of according thermostat, if called for the first time
				actualTempDev = hmDevice(iseId: actualTempId, hmType: "gauge", iconType: "")
				dynamicHmDevs.append(actualTempDev)
			}
			// get value of according HM-device
			actualTempDev.getState()
			
			return actualTempDev.state ?? 12.0
		}
		return -1.0
	}
	
	func triggerThermMode(mode: String) {
		let modeId = hmDevList.getThermDtPtViaIseId(searchId: hmDevices[self.indexName()]!.iseId, searchMode: "\(mode)_MODE")
		if (modeId != -1) {
			var modeDev: hmDevice
			// already created?
			if let foundDev = dynamicHmDevs.first(where: {$0.iseId == modeId}) {
				// reference to the former created virtual (sub-)device
				modeDev = foundDev
			} else {
				// create virtual (sub-)device of according thermostat, if called for the first time
				modeDev = hmDevice(iseId: modeId, hmType: "trigger", iconType: "")
				dynamicHmDevs.append(modeDev)
			}
			// set comfort-mode of according HM-device
			modeDev.setState(newValue: 1.0)
		}
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

// extension to return sorted array of dictionaries by 1. btnGrp ascending, 2. orderId within btnGrp ascending
/*extension hmDevice: Comparable {
	public static func == (lhs: hmDevice, rhs: hmDevice) -> Bool {
		return lhs.btnGrp == rhs.btnGrp && lhs.orderId == rhs.orderId
	}

	public static func < (lhs: hmDevice, rhs: hmDevice) -> Bool {
		// if btnGrps are the same, compare orderIds; otherwise compare btnGrps
		if lhs.btnGrp == rhs.btnGrp {
			return lhs.orderId < rhs.orderId
		} else {
			return lhs.btnGrp < rhs.btnGrp
		}
	}
}*/
