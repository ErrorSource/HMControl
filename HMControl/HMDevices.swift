//
//  HMDevices.swift
//  HMControl
//
//  Created by Georg Kemser on 15.03.21.
//

import Cocoa
import Foundation


extension hmDevice {
	// inital definition of all HM-device, that should be controled via app
	
	// iseId:    (int)          unique identifier-ID of Homematic device
	// hmType:                  actor = toggle | thermostat = slider | gauge = value in label | trigger = oneshot | ...
	// btnGrp:   (int)          group buttons in stackview (max. 4 buttons!)
	// orderId:  (int)          order of buttons/thermostats within stackviews
	// iconType:                part of image name 'btn_{iconType}_[off_on_unkown]'
	// minVal:   (float;  0.0)  minimum value, device can inherit
	// maxVal:   (float;  1.0)  maximum value, device can inherit
	// breakSec: (int;      1)  some devices need some time, till they can "react" again (because of ramp-time etc.)
	// state:    (float; -1.0)  actual state of device (-1.0 = "state could not be determined")
	
	static let definition: [String: hmDevice] = [
		// *** lights ***
		// group 1 ---------------------------------
		"Leuchtkugel": hmDevice(
			iseId: 1894,
			hmType: "actor",
			btnGrp: 1,
			orderId: 1,
			iconType: "LightBulb"
		),
		"Artischocke": hmDevice(
			iseId: 1687,
			hmType: "actor",
			btnGrp: 1,
			orderId: 2,
			iconType: "LightBulb"
		),
		"Sofa Leselicht": hmDevice(
			iseId: 2060,
			hmType: "actor",
			btnGrp: 1,
			orderId: 3,
			iconType: "LightBulb"
		),
		
		// group 2 ---------------------------------
		"Esstischlicht": hmDevice(
			iseId: 56153,
			hmType: "actor",
			btnGrp: 2,
			orderId: 1,
			iconType: "CeilLight",
			maxVal: 0.1,
			breakSec: 3
		),
		// group 3 ---------------------------------
		"Licht oben": hmDevice(
			iseId: 46134,
			hmType: "actor",
			btnGrp: 3,
			orderId: 1,
			iconType: "LightBulb"
		),
		"Leselicht oben": hmDevice(
			iseId: 2186,
			hmType: "actor",
			btnGrp: 3,
			orderId: 2,
			iconType: "LightBulb"
		),
		"TV-Licht": hmDevice(
			iseId: 33309,
			hmType: "actor",
			btnGrp: 3,
			orderId: 3,
			iconType: "LightBulb",
			breakSec: 5
		),
		
		// group 3 ---------------------------------
		// *** other actors/progs ***
		"Stereoanlage": hmDevice(
			iseId: 1997,
			hmType: "actor",
			btnGrp: 4,
			orderId: 2,
			iconType: "LightBulb"
		),
		"Mucke aufwecken": hmDevice(
			iseId: 11008,
			hmType: "actor",
			btnGrp: 4,
			orderId: 2,
			iconType: "LightBulb"
		),
		"Drucker": hmDevice(
			iseId: 52613,
			hmType: "actor",
			btnGrp: 4,
			orderId: 1,
			iconType: "Printer",
			breakSec: 3
		),
		
		// *** thermostates ***
		"Wohnzimmer": hmDevice(
			iseId: 4011,
			hmType: "thermostat",
			orderId: 1,
			iconType: "Thermostat",
			minVal: 19.0,
			maxVal: 23.0,
			breakSec: 3
		),
		"Galerie": hmDevice(
			iseId: 17480,
			hmType: "thermostat",
			orderId: 2,
			iconType: "Thermostat",
			minVal: 19.0,
			maxVal: 23.0,
			breakSec: 3
		),
		"Bad": hmDevice(
			iseId: 6534,
			hmType: "thermostat",
			orderId: 3,
			iconType: "Thermostat",
			minVal: 19.0,
			maxVal: 23.0,
			breakSec: 3
		)
	]
}

let hmDevList = hmStateList()

class hmStateList {
	let stateListLocation: String = "http://10.10.10.90/config/xmlapi/statelist.cgi"
	var initialReadingDone: Bool = false
	var firstReadingUTC: Double = NSDate().timeIntervalSince1970
	var lastReadingUTC: Double = 1609459200 // 1.1.2021
	var xmlObject: XMLIndexer?

	func startXMLReading(completionHandler: @escaping (_ response : XMLIndexer) -> ()) {
		self.initialReadingDone = false
		Utils.readHMStateList(location: stateListLocation) { (result) in
			self.xmlObject = SWXMLHash.lazy(result)
			self.lastReadingUTC = NSDate().timeIntervalSince1970
			completionHandler(self.xmlObject!)
		};
	}
	
	func getDtPtValue(searchId: Int) -> Float {
		let xmlStruct = self.xmlObject
		
		for device in xmlStruct!["stateList"]["device"].all {
			for channel in device["channel"].all {
				let trgtChannel = channel
				for datapoint in channel["datapoint"].all {
					if (datapoint.element?.attribute(by: "ise_id")?.text == String(searchId)) {
						guard let trgtValue = try? trgtChannel["datapoint"].withAttribute("ise_id", "\(searchId)").element?.attribute(by: "value")?.text else { return -1.0 }
						return (Float(Utils.calcState(trgtState: String(trgtValue))))
					}
				}
			}
		}
		// nothing found?
		return -1.0
	}
	
	func getThermDtPtViaIseId(searchId: Int, searchMode: String) -> Int {
		let xmlStruct = self.xmlObject

		for device in xmlStruct!["stateList"]["device"].all {
			for channel in device["channel"].all {
				let trgtChannel = channel
				for datapoint in channel["datapoint"].all {
					if (datapoint.element?.attribute(by: "ise_id")?.text == String(searchId)) {
						if let trgtId = try! trgtChannel["datapoint"].withAttribute("type", "\(searchMode.uppercased())").element?.attribute(by: "ise_id")?.text {
							return (Int(trgtId))!
						} else {
							return -1
						}
					}
				}
			}
		}
		// nothing found?
		return -1
	}
}
