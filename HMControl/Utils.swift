//
//  Helper.swift
//  HMControl
//
//  Created by Georg Kemser on 27.02.21.
//

import Foundation

class Utils {
	/*static func doAsyncHTTPGetRequest(location: String) {
		let url = URL(string: location)!
		let httpTask = URLSession.shared.dataTask(with: url) {(data, response, error) in
			guard data != nil else { return }
			// gk76: just for debugging, do not care about returned data
			guard let data = data else { return }
			print("doAsyncHTTPGetRequest Data: \(String(data: data, encoding: .utf8)!)")
		}
		
		httpTask.resume()
	}*/
	
	static func setHMStateViaHTTPGetRequest(_ reqDev: hmDevice, location: String) {
		let url = URL(string: location)!
		if let xmlString = try? String(contentsOf: url) {
			let xmlHash = SWXMLHash.parse(xmlString)
			do {
				let retVal = try xmlHash["result"]["changed"].withAttribute("id", String(reqDev.iseId)).element?.attribute(by: "new_value")?.text
				reqDev.state = (retVal != nil) ? calcState(trgtState: retVal!) : -1.0
			} catch _ { return }
		}
	}
	
	// gk76: for big xml-structures:
	//       let xml = SWXMLHash.config {
	//           config in
	//           config.shouldProcessLazily = true
	//       }.parse(xmlToParse)
	static func readXMLViaHTTPGetRequest(_ reqDev: hmDevice, location: String) {
		let url = URL(string: location)!
		if let xmlString = try? String(contentsOf: url) {
			let xmlHash = SWXMLHash.parse(xmlString)
			do {
				let retVal = try xmlHash["state"]["datapoint"].withAttribute("ise_id", String(reqDev.iseId)).element?.attribute(by: "value")?.text
				reqDev.state = (retVal != nil) ? calcState(trgtState: retVal!) : -1.0
			} catch _ { return }
		}
	}
	
	// xml-api of HM returns not only float-values; boolean values also possible
	static func calcState(trgtState: String) -> Float {
		var corrState: Float = 0.0
		if let floatState = Float(trgtState) {
			corrState = floatState;
		} else if (trgtState != "") {
			switch trgtState {
			case "false": corrState = 0.0;
			case "true": corrState = 1.0;
			default:
				corrState = -1.0; // value for error
			}
		} else {
			corrState = -1.0; // value for error
		}
		
		return corrState
	}
}
