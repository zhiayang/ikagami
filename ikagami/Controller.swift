//
//  State.swift
//  ikagami
//
//  Created by zhiayang on 2/2/23.
//

import Combine
import Foundation
import AVFoundation

class Controller : ObservableObject {

	static var instance = Controller()

	@Published public private(set) var captureDevices: [AVCaptureDevice] = []
	@Published public private(set) var selectedDevice: AVCaptureDevice? = nil

	private var hasPermission: Bool = false
	private var screenController = ScreenController()
	private var notificationSubscribers = Set<AnyCancellable>()
	private var connectToFirstDevice: Bool = false
	private var pauseOnStartup: Bool = false

	init() { }

	func devices() -> [Device] {
		return self.captureDevices.map({ dev in
			return Device(name: dev.localizedName, model: dev.modelID, uniqueId: dev.uniqueID)
		})
	}

	func select(device: Device?) {
		self.selectedDevice = nil

		if let device = device {
			for dev in self.captureDevices {
				if dev.uniqueID == device.uniqueId {
					self.selectedDevice = dev
					print("selected \(dev.localizedName), \(dev.uniqueID)")
					break
				}
			}
		} else {
			print("deselected device")
		}

		self.screenController.select(device: self.selectedDevice)
	}

	func screen() -> ScreenController {
		return self.screenController
	}



	func setup(connectToFirstDevice: Bool, pauseOnStartup: Bool) {
		self.connectToFirstDevice = connectToFirstDevice
		self.pauseOnStartup = pauseOnStartup

		_ = allowScreenCaptureDevices()

		requestPermissionForMediaType(type: .video, callback: { [unowned self] (ok: Bool) in
			print("granted = \(ok)")
			guard ok else {
				return
			}

			self.updateDeviceList()
			self.hasPermission = true
		})

		NotificationCenter.default.publisher(for: NSNotification.Name.AVCaptureDeviceWasConnected)
			.sink(receiveValue: { _ in self.updateDeviceList() })
			.store(in: &self.notificationSubscribers)

		NotificationCenter.default.publisher(for: NSNotification.Name.AVCaptureDeviceWasDisconnected)
			.sink(receiveValue: { _ in self.updateDeviceList() })
			.store(in: &self.notificationSubscribers)

	}

	private func updateDeviceList() {
		let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown], mediaType: .muxed, position: .unspecified)
		print("updated devices list (\(discoverySession.devices.count)):")
		for device in discoverySession.devices {
			print("  \(device.localizedName)")
		}

		self.captureDevices = discoverySession.devices

		if self.connectToFirstDevice && !self.screenController.haveDevice && self.captureDevices.count > 0 {

			self.selectedDevice = self.captureDevices.first
			self.screenController.select(device: self.selectedDevice)

			if self.pauseOnStartup {
				self.screenController.pause()
			}
		}
	}
}
