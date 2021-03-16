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
	static let definition: [String: hmDevice] =  [
		"Artischocke": hmDevice(
			iseId: 1687,
			hmType: "actor",
			olName: "btnArtischocke", // has to be the name of corresponding outlet!
			iconType: "LightBulb", // part of image name
			minVal: 0.0,
			maxVal: 1.0,
			breakSec: 1,
			state: -1.0
		),
		"Sofa Leselicht": hmDevice(
			iseId: 2060,
			hmType: "actor",
			olName: "",
			iconType: "LightBulb", // part of image name
			minVal: 0.0,
			maxVal: 1.0,
			breakSec: 1,
			state: -1.0
		),
		"Esstischlicht": hmDevice(
			iseId: 56153,
			hmType: "actor",
			olName: "btnEsstisch", // has to be the name of corresponding outlet!
			iconType: "CeilLight", // part of image name
			minVal: 0.0,
			maxVal: 0.1,
			breakSec: 3,
			state: -1.0
		),
		"Drucker": hmDevice(
			iseId: 52613,
			hmType: "actor",
			olName: "",
			iconType: "LightBulb", // part of image name
			minVal: 0.0,
			maxVal: 1.0,
			breakSec: 3,
			state: -1.0
		),
		"TV-Licht": hmDevice(
			iseId: 33309,
			hmType: "actor",
			olName: "btnTVLicht", // has to be the name of corresponding outlet!
			iconType: "LightBulb", // part of image name
			minVal: 0.0,
			maxVal: 1.0,
			breakSec: 5,
			state: -1.0
		)
	]
}
