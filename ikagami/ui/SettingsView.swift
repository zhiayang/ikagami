//
//  SettingsView.swift
//  ikagami
//
//  Created by zhiayang on 2/2/23.
//

import SwiftUI

struct SettingsView: View {

	// settings stuff
	@AppStorage("pauseOnStartup") private var pauseOnStartup = false
	@AppStorage("autoConnectToFirstDevice") private var autoConnectToFirstDevice = false

	@ObservedObject private var controller: Controller
	@Binding private var selectedDevice: Device?

	init(controller: Controller) {
		self.controller = controller

		self._selectedDevice = Binding(get: {
			return controller.selectedDevice?.toDevice()
		}, set: {
			controller.select(device: $0)
		})
	}

    var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Picker("device: ", selection: self.$selectedDevice) {
					Text("none").tag(Optional<Device>.none)

					ForEach(self.controller.devices()) { dev in
						Text("\(dev.name) (\(dev.model))").tag(Optional(dev))
					}
				}
				.frame(minWidth: 150)
			}

			Toggle(isOn: self.$autoConnectToFirstDevice) {
				Text("automatically connect to first device")
			}

			Toggle(isOn: self.$pauseOnStartup) {
				Text("pause on startup")
			}
		}
		.frame(minWidth: 200)
		.padding(.all, 20)
		.fixedSize()
    }
}
