//
//  Device.swift
//  ikagami
//
//  Created by zhiayang on 3/2/23.
//

import Foundation
import AVFoundation

struct Device : Hashable, Identifiable
{
	var id: String { self.uniqueId }

	let name: String
	let model: String
	let uniqueId: String
}


extension AVCaptureDevice {
	func toDevice() -> Device {
		return Device(name: self.localizedName, model: self.modelID, uniqueId: self.uniqueID)
	}
}
