//
//  ImageCapture.swift
//  ikagami
//
//  Created by zhiayang on 3/2/23.
//

import Cocoa
import SwiftUI
import CoreImage
import Foundation
import CoreGraphics
import AVFoundation

class ScreenController : NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate
{
	private static let defaultMinimumSize = NSSize(width: 100, height: 100)

	private var captureSession: AVCaptureSession
	private var capturePreviewLayer: AVCaptureVideoPreviewLayer
	private var captureOutput: AVCapturePhotoOutput
	private var captureDelegate: PhotoCaptureDelegate!

	private var captureInput: AVCaptureDeviceInput? = nil
	private var boundWindow: Binding<NSWindow?>? = nil

	private var queue = DispatchQueue(label: "queue")
	private var unpausing = false

	@Published public private(set) var paused: Bool = false
	@Published public private(set) var frozen: Bool = false
	@Published public private(set) var haveDevice: Bool = false
	@Published public private(set) var staticImage: CGImage? = nil
	@Published public private(set) var minimumSize: NSSize = ScreenController.defaultMinimumSize

	override init() {
		self.captureSession = AVCaptureSession()

		self.capturePreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
		self.capturePreviewLayer.videoGravity = .resizeAspect

		self.captureOutput = AVCapturePhotoOutput()
		super.init()

		self.captureDelegate = PhotoCaptureDelegate(self)
	}

	func togglePaused() {
		guard self.haveDevice else {
			return
		}

		if self.paused {
			self.unpause()
		} else {
			self.pause()
		}
	}

	func pause() {
		self.paused = true
		guard self.captureSession.isRunning else {
			return
		}

		DispatchQueue.main.async {
			let settings = AVCapturePhotoSettings()
			self.captureOutput.capturePhoto(with: settings, delegate: self.captureDelegate)
		}
	}

	func unpause() {
		guard !self.captureSession.isRunning && !self.unpausing else {
			return
		}

		self.unpausing = true
		self.queue.async {
			// startRunning() is synchronous and might take a while, so don't do it
			// on the main thread. only set paused = false when it's done.
			print("resuming")
			self.captureSession.startRunning()

			DispatchQueue.main.async {
				self.paused = false
				self.unpausing = false
			}
		}
	}


	func session() -> AVCaptureSession {
		return self.captureSession
	}

	func previewLayer() -> AVCaptureVideoPreviewLayer {
		return self.capturePreviewLayer
	}

	func isPaused() -> Bool {
		return self.paused
	}

	func bindTo(window: Binding<NSWindow?>) {
		self.boundWindow = window
	}


	func select(device: AVCaptureDevice?) {
		if self.captureSession.isRunning {
			self.captureSession.stopRunning()
		}

		self.haveDevice = false
		if self.captureInput != nil {
			self.captureSession.removeInput(self.captureInput!)
		}

		self.captureSession.removeOutput(self.captureOutput)
		guard let device = device else {
			return
		}

		guard let input = try? AVCaptureDeviceInput(device: device) else {
			print("could not create AVCaptureDeviceInput")
			return
		}

		self.captureInput = input
		self.captureSession.beginConfiguration()
		self.captureSession.addInput(self.captureInput!)
		self.captureSession.addOutput(self.captureOutput)

		self.captureSession.commitConfiguration()

		var didLockDevice = false
		do {
			try device.lockForConfiguration()
			didLockDevice = true
		} catch {
			print("can't lock device")
		}

		if !self.paused {
			print("starting capture session")

			self.queue.async {
				self.captureSession.startRunning()

				DispatchQueue.main.async {
					// get the resolution
					let settings = AVCapturePhotoSettings()
					self.captureOutput.capturePhoto(with: settings, delegate: self.captureDelegate)
				}
			}
		}

		// unlock the device only after we start the session, so that the settings don't change.
		if didLockDevice {
			device.unlockForConfiguration()
		}

		self.haveDevice = true
	}

	private class PhotoCaptureDelegate : NSObject, AVCapturePhotoCaptureDelegate
	{
		private unowned var parent: ScreenController

		init(_ parent: ScreenController) {
			self.parent = parent
		}

		func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
			let dims = photo.resolvedSettings.photoDimensions
			let size = NSSize(width: CGFloat(dims.width), height: CGFloat(dims.height))

			if self.parent.paused {
				self.parent.session().stopRunning()
			}

			DispatchQueue.main.async {
				self.parent.staticImage = photo.cgImageRepresentation()

				guard let windowBinding = self.parent.boundWindow, let window = windowBinding.wrappedValue else {
					print("warning: no window?")
					return
				}

				guard size.width > 0 && size.height > 0 else {
					print("invalid size \(size)")
					self.parent.minimumSize = ScreenController.defaultMinimumSize
					return
				}

				print("size = \(size)")
				window.aspectRatio = size

				let aspect = size.width / size.height
				self.parent.minimumSize = NSSize(width: 150, height: 150 / aspect - window.titlebarHeight)
			}
		}
	}
}

extension NSWindow {
	var titlebarHeight: CGFloat {
		self.frame.height - self.contentLayoutRect.height
	}
}
