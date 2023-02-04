//
//  ScreenViewWrapper.swift
//  ikagami
//
//  Created by zhiayang on 3/2/23.
//

import Cocoa
import SwiftUI
import Foundation
import AVFoundation

struct ScreenViewWrapper : NSViewRepresentable
{
	public typealias NSViewType = NSView

	private let paused: Bool
	private let background: CALayer
	private let screen: ScreenController

	private let previewLayer: CALayer

	init(for screen: ScreenController, isPaused: Bool)
	{
		self.background = CALayer()
		self.screen = screen
		self.paused = isPaused

		self.previewLayer = self.screen.previewLayer()
	}

	func makeNSView(context: Context) -> NSView
	{
		let view = NSView()
		view.layer = self.previewLayer

		return view
	}

	func updateNSView(_ view: NSView, context: Context)
	{
		if self.paused {
			self.background.contents = self.screen.staticImage
			view.layer = self.background
		} else {
			view.layer = self.previewLayer
		}

		view.updateLayer()
	}

	func makeCoordinator() -> Coordinator
	{
		return Coordinator()
	}

	final class Coordinator : NSObject
	{
	}
}
