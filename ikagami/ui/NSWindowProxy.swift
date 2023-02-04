//
//  NSWindowProxy.swift
//  ikagami
//
//  Created by zhiayang on 3/2/23.
//

import Cocoa
import SwiftUI
import Foundation

struct NSWindowProxy : NSViewRepresentable {
	@Binding var window: NSWindow?

	func makeNSView(context: Context) -> NSView {
		let view = NSView()
		DispatchQueue.main.async {
			self.window = view.window
		}
		return view
	}

	func updateNSView(_ nsView: NSView, context: Context) {
		
	}
}
