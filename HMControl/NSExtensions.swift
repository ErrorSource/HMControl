//
//  Extensions.swift
//  HMControl
//
//  Created by Georg Kemser on 25.03.21.
//

import Foundation
import Cocoa

extension String {
	func capturedGroups(withRegex pattern: String) -> [String] {
		var results = [String]()

		var regex: NSRegularExpression
		do {
			regex = try NSRegularExpression(pattern: pattern, options: [])
		} catch {
			return results
		}
		let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))

		guard let match = matches.first else { return results }

		let lastRangeIndex = match.numberOfRanges - 1
		guard lastRangeIndex >= 1 else { return results }

		for i in 1...lastRangeIndex {
			let capturedGroupIndex = match.range(at: i)
			let matchedString = (self as NSString).substring(with: capturedGroupIndex)
			results.append(matchedString)
		}

		return results
	}
}

extension String {
	var temperatureString: String {
		guard let float = Float(self) else { return "-1,0°C" }
		
		let tempFrmttr = NumberFormatter()
		tempFrmttr.minimumIntegerDigits = 2
		tempFrmttr.maximumFractionDigits = 1
		tempFrmttr.minimumFractionDigits = 1
		tempFrmttr.decimalSeparator = ","
		
		let frmttdStrg = tempFrmttr.string(from: NSNumber(value: float))!
		
		if (frmttdStrg != "") { return "\(frmttdStrg)°C" } else { return "-1,0°C" }
	}
}

extension NSImage {
	func scaledCopy( sizeOfLargerSide: CGFloat) -> NSImage {
		var newW: CGFloat
		var newH: CGFloat
		var scaleFactor: CGFloat
		
		if (self.size.width > self.size.height) {
			scaleFactor = self.size.width / sizeOfLargerSide
			newW = sizeOfLargerSide
			newH = self.size.height / scaleFactor
		} else{
			scaleFactor = self.size.height / sizeOfLargerSide
			newH = sizeOfLargerSide
			newW = self.size.width / scaleFactor
		}
		
		return resizedCopy(w: newW, h: newH)
	}
	
	func resizedCopy(w: CGFloat, h: CGFloat) -> NSImage {
		let destSize = NSMakeSize(w, h)
		let newImage = NSImage(size: destSize)
		
		newImage.lockFocus()
		
		self.draw(in: NSRect(origin: .zero, size: destSize),
				  from: NSRect(origin: .zero, size: self.size),
				  operation: .copy,
				  fraction: CGFloat(1)
		)
		
		newImage.unlockFocus()
		
		guard let data = newImage.tiffRepresentation,
			  let result = NSImage(data: data)
		else { return NSImage() }
		
		return result
	}
}

extension NSObject {
	private struct AssociatedKeys {
		static var idDescriptiveName = "objIdntfr"
		static var stDescriptiveName = "objStoredVal"
	}
	
	var objIdntfr: String? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.idDescriptiveName) as? String
		}
		
		set {
			if let newValue = newValue {
				objc_setAssociatedObject(
					self,
					&AssociatedKeys.idDescriptiveName,
					newValue as NSString?,
					.OBJC_ASSOCIATION_RETAIN_NONATOMIC
				)
			}
		}
	}
	
	var objStoredVal: String? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.stDescriptiveName) as? String
		}
		
		set {
			if let newValue = newValue {
				objc_setAssociatedObject(
					self,
					&AssociatedKeys.stDescriptiveName,
					newValue as NSString?,
					.OBJC_ASSOCIATION_RETAIN_NONATOMIC
				)
			}
		}
	}
}

// extension need in getViewElementByObjIdntfr for recursive search of subviews
extension NSView {
	func findViews<T: NSView>() -> [T] {
		return recursiveSubviews.compactMap { $0 as? T }
	}

	var recursiveSubviews: [NSView] {
		return subviews + subviews.flatMap { $0.recursiveSubviews }
	}
}
