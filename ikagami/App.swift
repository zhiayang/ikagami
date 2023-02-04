//
//  ikagamiApp.swift
//  ikagami
//
//  Created by zhiayang on 2/2/23.
//

import SwiftUI
import AVFoundation

@main
struct ikagamiApp: App {

	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

	@State var nsWindow: NSWindow? = nil
	@ObservedObject private var controller: Controller
	@ObservedObject private var screenController: ScreenController

	private var mouseTracker: MouseTracker!

	init() {
		self.controller = Controller.instance
		self.screenController = Controller.instance.screen()

		self.mouseTracker = MouseTracker(self.setControlButtonVisibility(_:))

		let pauseOnStartup = UserDefaults.standard.bool(forKey: "pauseOnStartup")
		let autoConnectToFirstDevice = UserDefaults.standard.bool(forKey: "autoConnectToFirstDevice")

		self.controller.setup(connectToFirstDevice: autoConnectToFirstDevice, pauseOnStartup: pauseOnStartup)
	}

    var body: some Scene {
        WindowGroup {
			ZStack {
				ShortcutMaker(shortcuts: ["k", " "], action: {
					self.screenController.togglePaused()
				})

				ScreenView(controller: self.controller, nsWindow: self.$nsWindow)
			}
			.frame(minWidth: self.screenController.minimumSize.width, minHeight: self.screenController.minimumSize.height)
			.background(NSWindowProxy(window: self.$nsWindow))
			.edgesIgnoringSafeArea(.top)
		}
		.commands(content: {
			CommandGroup(replacing: .newItem) {}
		})
		.windowStyle(.hiddenTitleBar)
		.windowToolbarStyle(.unifiedCompact)

		Settings {
			SettingsView(controller: self.controller)
		}
    }

	private func setControlButtonVisibility(_ visible: Bool) {
		NSApp.mainWindow?.standardWindowButton(.zoomButton)?.superview?.animator().alphaValue = (visible ? 1.0 : 0.0)
		NSApp.mainWindow?.standardWindowButton(.closeButton)?.superview?.animator().alphaValue = (visible ? 1.0 : 0.0)
		NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.superview?.animator().alphaValue = (visible ? 1.0 : 0.0)
	}
}





// swiftui is dumb
class AppDelegate : NSObject, NSApplicationDelegate {
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
}


