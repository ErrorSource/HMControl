//
//  AppDelegate.swift
//  HMControl
//
//  Created by Georg Kemser on 25.02.21.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	var mainVC:PopupVC!
	var eventMonitor: EventMonitor?
	let statusBarItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
	let popupView = NSPopover()
	
	// gk76: this is the menu-functionality! shows a menu on click of menubar-icon
	//       -> use this for right-click! tbd
	/*func applicationDidFinishLaunching(_ aNotification: Notification) {
		// icon for menubar
		//let icon = NSImage(imageLiteralResourceName: "MenuIcon")
		// icon?.setTemplate(true)  // on bitmaps without transparency
		//statusBarItem.image = icon
		if let button = statusBarItem.button {
			button.image = NSImage(named:NSImage.Name("MenuIcon"))
			//button.action = #selector(printQuote(_:))
		}
		
		// build menubar-menu (right-click) -> tbd!!!
		constructMenu()
	}*/
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		if let button = statusBarItem.button {
			button.image = NSImage(named:NSImage.Name("MenuIcon"))
			button.action = #selector(togglePopupView(_:))
		}
		popupView.contentViewController = PopupVC.freshController()
		
		// read all HM-device states (for setting according icon)
		//print("hmDevicesState1687: \(String(describing: hmDevices["Artischocke"]?.getState()))")
		
		// close popup, if mouse-click is outside popup (using EventMonitor)
		eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
			if let strongSelf = self, strongSelf.popupView.isShown {
				strongSelf.closePopupView(sender: event)
			}
		}
	}
	
	func constructMenu() {
		// add menu-entries
		let menu: NSMenu = NSMenu()
		
		// Settings
		var menuItem  = NSMenuItem()
		menuItem.title = "Einstellungen"
		menuItem.action = #selector(AppDelegate.showMyWindow(_:))
		menuItem.keyEquivalent = "S"
		menu.addItem(menuItem)
		
		// Seperator
		menu.addItem(NSMenuItem.separator())
		
		// Quit
		menuItem  = NSMenuItem()
		menuItem.title = "Beenden"
		menuItem.action = #selector(AppDelegate.quit(_:))
		menuItem.keyEquivalent = "q"
		menu.addItem(menuItem)
		
		// connect menu with menubar-element
		statusBarItem.menu = menu
	}
	
	// toggle popup
	@objc func togglePopupView(_ sender: Any?) {
		if popupView.isShown {
			closePopupView(sender: sender)
		} else {
			showPopupView(sender: sender)
		}
	}
	
	// show popup
	func showPopupView(sender: Any?) {
		if let button = statusBarItem.button {
			popupView.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
		}
		eventMonitor?.start()
	}
	
	// close popup
	func closePopupView(sender: Any?) {
		popupView.performClose(sender)
		eventMonitor?.stop()
	}
	
	// reaction on menu-entry "Settings"
	@objc func showMyWindow(_ sender:NSMenuItem) {
		mainVC?.view.window?.makeKeyAndOrderFront(self)
	}
	// reaction on menu-entry "Quit"
	@objc func quit(_ sender:NSMenuItem) {
		NSApplication.shared.terminate(self)
	}
}
