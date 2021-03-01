//
//  Helper.swift
//  HMControl
//
//  Created by Georg Kemser on 27.02.21.
//

import Foundation

class Utils {
	static func doAsyncHTTPGetRequest(location: String) {
		let url = URL(string: location)!
		let httpTask = URLSession.shared.dataTask(with: url) {(data, response, error) in
			guard data != nil else { return }
			// gk76: just for debugging, do not care about returned data
			//guard let data = data else { return }
			//print("doAsyncHTTPGetRequest Data: \(String(data: data, encoding: .utf8)!)")
		}
		
		httpTask.resume()
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
				let hmState = try xmlHash["state"]["datapoint"].withAttribute("ise_id", String(reqDev.iseId)).element?.attribute(by: "value")?.text
				if let hmFltState = Float(hmState!) {
					reqDev.state = hmFltState;
				} else if (hmState != nil) {
					switch hmState! {
					case "false": reqDev.state = 0.0;
					case "true": reqDev.state = 1.0;
					default:
						reqDev.state = -1.0;
					}
				} else {
					reqDev.state = -1.0;
				}
			} catch _ { return }
		}
	}
}
