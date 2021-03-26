//
//  PopupElements.swift
//  HMControl
//
//  Created by Georg Kemser on 23.03.21.
//

import Cocoa
import Foundation

extension PopupVC {
	// actor-buttons (toggle) ------------------------------------------------
	func createHMToggleButton(devName: String, devObj: hmDevice) -> NSButton {
		// set the actual button-states
		let hmBtnState = (devObj.deviceIsOn()) ? "on" : "off"
		let greyTitleColor = NSColor(red: 160.0, green: 160.0, blue: 160.0, alpha: 1.0)
		
		let hmBtn = NSButton() as NSButton
		hmBtn.objIdntfr = "\(devObj.iseId)_tgglBtn"
		//hmBtn.title = devName
		//NSFont.systemFont(ofSize: NSFont.systemFontSize)
		hmBtn.attributedTitle = NSAttributedString(string: devName, attributes: [ NSAttributedString.Key.foregroundColor : greyTitleColor,  NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12)])
		hmBtn.isBordered = false
		hmBtn.image = NSImage(named:"btn_\(devObj.iconType)_\(hmBtnState)")!.resizedCopy(w: 40.0, h:40.0)
		hmBtn.imagePosition = .imageAbove
		hmBtn.translatesAutoresizingMaskIntoConstraints = false
		
		hmBtn.target = self
		hmBtn.action = #selector(self.hmBtnActionToggle)
		
		// constrains: add hardcoded with-constrain to give space for title; otherwise buttons won't align at the same x-position
		hmBtn.widthAnchor.constraint(equalToConstant: 80).isActive = true
		
		return hmBtn
	}
	
	func createHMBtnParentStackview() -> NSStackView {
		let hmBntPrntSV = NSStackView()
		hmBntPrntSV.orientation = .vertical
		hmBntPrntSV.spacing = 20.0
		hmBntPrntSV.alignment = .leading
		hmBntPrntSV.distribution = .fillEqually
		hmBntPrntSV.translatesAutoresizingMaskIntoConstraints = false
		
		return hmBntPrntSV
	}
	
	func createHMBtnGrpStackview(btnGrpObj: [NSButton]) -> NSStackView {
		let hmBtnGrpSV = NSStackView(views: btnGrpObj)
		hmBtnGrpSV.orientation = .horizontal
		hmBtnGrpSV.spacing = 20.0
		hmBtnGrpSV.alignment = .centerY
		hmBtnGrpSV.distribution = .fillEqually
		
		return hmBtnGrpSV
	}
	
	func constrainsHMBtnParentStackview(hmBntPrntSV: NSStackView, popupView: NSView) {
		//btnGrpSV.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 50).isActive = true
		//btnGrpSV.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -50).isActive = true
		NSLayoutConstraint.activate([
			hmBntPrntSV.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
			hmBntPrntSV.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 40),
			//btnGrpSV.widthAnchor.constraint(equalToConstant: 254),
		])
	}
	// end actor-buttons (toggle) --------------------------------------------
	
	// thermostat-group (slider, buttons, labels) ----------------------------
	func createHMThrmGrpLabel(devName: String) -> NSTextField {
		let hmThrmGrpLbl = NSTextField() as NSTextField
		hmThrmGrpLbl.isEditable = false
		hmThrmGrpLbl.isSelectable = false
		hmThrmGrpLbl.isBezeled = false;
		hmThrmGrpLbl.lineBreakMode = .byClipping
		hmThrmGrpLbl.maximumNumberOfLines = 0
		hmThrmGrpLbl.stringValue = devName
		hmThrmGrpLbl.alignment = .center
		hmThrmGrpLbl.font = NSFont.systemFont(ofSize: 14)
		hmThrmGrpLbl.textColor = NSColor.systemBlue
		hmThrmGrpLbl.drawsBackground = false
		hmThrmGrpLbl.cell?.isScrollable = false
		hmThrmGrpLbl.cell?.wraps = false
		
		return hmThrmGrpLbl
	}
	
	func createHMThrmSlider(devName: String, devObj: hmDevice) -> NSSlider {
		let hmThrmSldr = NSSlider() as NSSlider
		hmThrmSldr.objIdntfr = "\(devObj.iseId)_sollSldr"
		hmThrmSldr.sliderType = .linear
		hmThrmSldr.numberOfTickMarks = 9
		hmThrmSldr.tickMarkPosition = .below
		hmThrmSldr.minValue = 19
		hmThrmSldr.maxValue = 23
		hmThrmSldr.allowsTickMarkValuesOnly = true
		hmThrmSldr.floatValue = devObj.state ?? 19.0
		
		// action: get value from slider and set target temperature of according HM-device
		hmThrmSldr.action = #selector(self.hmSldrThermAction(_:))
		
		return hmThrmSldr
	}
	
	func createHMThrmSollLbl(devObj: hmDevice) -> NSTextField {
		let hmThrmSoll = NSTextField() as NSTextField
		hmThrmSoll.objIdntfr = "\(devObj.iseId)_sollLbl"
		hmThrmSoll.objStoredVal = String(devObj.state!).temperatureString
		hmThrmSoll.isEditable = false
		hmThrmSoll.isSelectable = false
		hmThrmSoll.isBezeled = true;
		hmThrmSoll.bezelStyle = .roundedBezel
		hmThrmSoll.lineBreakMode = .byClipping
		hmThrmSoll.maximumNumberOfLines = 0
		hmThrmSoll.stringValue = String(devObj.state!).temperatureString
		hmThrmSoll.alignment = .center
		hmThrmSoll.font = NSFont.systemFont(ofSize: 18)
		hmThrmSoll.textColor = NSColor.white
		hmThrmSoll.backgroundColor = NSColor.lightGray
		hmThrmSoll.drawsBackground = true
		hmThrmSoll.cell?.isScrollable = false
		hmThrmSoll.cell?.wraps = false
		hmThrmSoll.translatesAutoresizingMaskIntoConstraints = false
		hmThrmSoll.widthAnchor.constraint(equalToConstant: 100).isActive = true
		hmThrmSoll.heightAnchor.constraint(equalToConstant: 30).isActive = true
		hmThrmSoll.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		hmThrmSoll.setContentCompressionResistancePriority(.required, for: .vertical)
		//hmThrmSoll.alignmentRect(forFrame: NSRect(x:0.0, y:0.0, width:100.0, height:30.0))
		
		return hmThrmSoll
	}
	
	func createHMThrmCtrlButtons(devName: String, devObj: hmDevice) -> [NSButton] {
		var btnGroup = [NSButton]()
		for trgtMode in ["Comfort", "Lowering", "Boost"] {
			let hmCtrlBtn = NSButton() as NSButton
			hmCtrlBtn.objIdntfr = "\(devObj.iseId)_\(trgtMode)Btn"
			hmCtrlBtn.objStoredVal = trgtMode
			hmCtrlBtn.isBordered = false
			hmCtrlBtn.title = ""
			hmCtrlBtn.image = NSImage(named:"btn_\(devObj.iconType)_\(trgtMode.lowercased())")!.resizedCopy(w: 20.0, h:20.0)
			hmCtrlBtn.imagePosition = .imageAbove
			hmCtrlBtn.translatesAutoresizingMaskIntoConstraints = false
			
			// action: set target temperature of according HM-device to corresponding mode-temperature
			hmCtrlBtn.action = #selector(self.hmCtrlBtnThermAction(_:))
			
			btnGroup.append(hmCtrlBtn)
		}
		
		return btnGroup
	}
	
	func createHMThrmIstLbl(devObj: hmDevice) -> NSTextField {
		// hmThrmIst.stringValue = actual temperature will be set in PopupVC after reading statelist XML
		let hmThrmIst = NSTextField() as NSTextField
		hmThrmIst.objIdntfr = "\(devObj.iseId)_istLbl"
		hmThrmIst.isEditable = false
		hmThrmIst.isSelectable = false
		hmThrmIst.isBezeled = false;
		hmThrmIst.lineBreakMode = .byClipping
		hmThrmIst.maximumNumberOfLines = 0
		hmThrmIst.alignment = .center
		hmThrmIst.font = NSFont.systemFont(ofSize: 12)
		hmThrmIst.textColor = NSColor.systemBlue
		hmThrmIst.drawsBackground = false
		hmThrmIst.cell?.isScrollable = false
		hmThrmIst.cell?.wraps = false
		hmThrmIst.translatesAutoresizingMaskIntoConstraints = false
		hmThrmIst.widthAnchor.constraint(equalToConstant: 100).isActive = true
		
		return hmThrmIst
	}
	
	func createHMThrmSliderSV(devName: String, devObj: hmDevice) -> NSStackView {
		// create soll-slider
		let hmThrmSldr: NSSlider = createHMThrmSlider(devName: devName, devObj: devObj)
		// create soll-label (in dependency of soll-slider)
		let hmThrmSoll: NSTextField = createHMThrmSollLbl(devObj: devObj)
		
		// put soll-slider and soll-label in a stackview
		let hmThrmSldrSV = NSStackView(views: [hmThrmSldr, hmThrmSoll])
		hmThrmSldrSV.orientation = .horizontal
		hmThrmSldrSV.spacing = 10.0
		hmThrmSldrSV.alignment = .centerY
		hmThrmSldrSV.distribution = .fillProportionally
		
		// create button-group for controlling thermostat: comfort, lowering, boost
		let hmThrmBtnGrp = createHMThrmCtrlButtons(devName: devName, devObj: devObj)
		// create ist-label (value from hmDevice)
		let hmThrmIst: NSTextField = createHMThrmIstLbl(devObj: devObj)
		
		let hmThrmCtrlBtnSV = NSStackView(views: hmThrmBtnGrp)
		hmThrmCtrlBtnSV.addArrangedSubview(hmThrmIst)
		hmThrmCtrlBtnSV.orientation = .horizontal
		hmThrmCtrlBtnSV.spacing = 10.0
		hmThrmCtrlBtnSV.alignment = .centerY
		hmThrmCtrlBtnSV.distribution = .fill
		
		let hmThrmGrpSV = NSStackView(views: [hmThrmSldrSV, hmThrmCtrlBtnSV])
		hmThrmGrpSV.orientation = .vertical
		hmThrmGrpSV.spacing = 5.0
		hmThrmGrpSV.alignment = .trailing
		hmThrmGrpSV.distribution = .fillEqually
		
		return hmThrmGrpSV
	}
	
	func createHMThrmSldrParentStackview() -> NSStackView {
		let hmThrmSldrPrntSV = NSStackView()
		hmThrmSldrPrntSV.orientation = .vertical
		hmThrmSldrPrntSV.spacing = 10.0
		hmThrmSldrPrntSV.alignment = .leading
		hmThrmSldrPrntSV.distribution = .fillEqually
		hmThrmSldrPrntSV.translatesAutoresizingMaskIntoConstraints = false
		
		return hmThrmSldrPrntSV
	}
	
	func createHMThrmGrpStackview(thrmGrpSV: Array<NSStackView>) -> NSStackView {
		let hmThrmGrpSV = NSStackView(views: thrmGrpSV)
		hmThrmGrpSV.orientation = .horizontal
		hmThrmGrpSV.spacing = 10.0
		hmThrmGrpSV.alignment = .centerY
		hmThrmGrpSV.distribution = .fillEqually
		
		return hmThrmGrpSV
	}
	
	func constrainsHMThrmSldrParentStackview(hmThrmSldrPrntSV: NSStackView, hmBntPrntSV: NSStackView, popupView: NSView) {
		NSLayoutConstraint.activate([
			hmThrmSldrPrntSV.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
			hmThrmSldrPrntSV.topAnchor.constraint(equalTo: hmBntPrntSV.bottomAnchor, constant: 40),
			hmThrmSldrPrntSV.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 40),
			hmThrmSldrPrntSV.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -40),
		])
	}
	
	func constrainsHMThrmSldrGrpStackview(hmThrmSldrGrpSV: NSStackView, subView: NSView) {
		NSLayoutConstraint.activate([
			hmThrmSldrGrpSV.leadingAnchor.constraint(equalTo: subView.leadingAnchor, constant: 0),
			hmThrmSldrGrpSV.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: 0),
		])
	}
	// end thermostat-group (slider, buttons, labels) ------------------------
	
	// generic ---------------------------------------------------------------
	func getViewElementByObjIdntfr(objIdntfr: String) -> NSView! {
		let allSubViewsRecursively = self.view.findViews()
		for subview in allSubViewsRecursively {
			if (subview.objIdntfr == objIdntfr) {
				return subview
			}
		}
		
		return NSView()
	}
	
	func getSVsOverallHeight() -> Int {
		var ovrllHeight: Int = 0
		// itterate only though "top-stackviews"
		for subview in self.view.subviews {
			if (subview.className == "NSStackView") {
				ovrllHeight += Int(subview.frame.size.height)
			}
		}
		return ovrllHeight
	}
	// end generic -----------------------------------------------------------
}
