//
//  PlatformSetup.swift
//  ikagami
//
//  Created by zhiayang on 2/2/23.
//

import AppKit
import Foundation
import CoreMediaIO
import AVFoundation

func allowScreenCaptureDevices() -> Bool {
	var property = CMIOObjectPropertyAddress(
		mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
		mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
		mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster)
	)

	var allow: UInt32 = 1
	let result = CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject),
										   &property, 0, nil, 4, &allow)

	guard result == 0 else {
		let alert = NSAlert()
		alert.alertStyle = .critical
		alert.addButton(withTitle: "OK")
		alert.messageText = "failed to allow screen capture devices: \(result)"
		alert.runModal()
		return false
	}

	return true
}


func requestPermissionForMediaType(type: AVMediaType, callback: @escaping (Bool) -> Void) {
	switch AVCaptureDevice.authorizationStatus(for: type)
	{
		case .authorized:
			callback(true)

		case .notDetermined:
			AVCaptureDevice.requestAccess(for: type, completionHandler: { (granted: Bool) in
				callback(granted)
			})

		case .denied: fallthrough;
		case .restricted:
			callback(false)

		@unknown default:
			fatalError()
	}
}
