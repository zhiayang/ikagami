//
//  MouseInside.swift
//  ikagami
//
//  Created by zhiayang on 3/2/23.
//

import AppKit
import SwiftUI
import Foundation

class MouseTrackResponder : NSResponder {

	var callback: ((Bool) -> Void)?

	override func mouseEntered(with event: NSEvent) {
		self.callback?(true)
	}

	override func mouseExited(with event: NSEvent) {
		self.callback?(false)
	}
}

class MouseTracker {

	private var view: NSView?
	private var responder: MouseTrackResponder

	init(_ callback: @escaping (Bool) -> Void) {
		self.responder = MouseTrackResponder()
		self.responder.callback = callback

		DispatchQueue.main.async { [unowned self] in
			if let window = NSApp.windows.first {
				window.makeKeyAndOrderFront(self)
				window.isMovableByWindowBackground = true

				self.responder.callback?(false)

				self.setupTrackingArea(in: window)
			}
		}
	}

	private func setupTrackingArea(in window: NSWindow) {
		self.view = NSView(frame: window.frame)

		let options: NSTrackingArea.Options = [
			.mouseEnteredAndExited,
			.inVisibleRect,
			.activeInKeyWindow,
		]

		let trackingArea = NSTrackingArea(rect: window.frame,
										  options: options,
										  owner: self.responder,
										  userInfo: nil)

		window.contentView?.addTrackingArea(trackingArea)
	}
}
