//
//  ScreenView.swift
//  ikagami
//
//  Created by zhiayang on 3/2/23.
//

import Cocoa
import SwiftUI
import Foundation

struct ScreenView : View {

	@Binding var nsWindow: NSWindow?

	@ObservedObject var controller: Controller
	@ObservedObject var screenController: ScreenController

	init(controller: Controller, nsWindow: Binding<NSWindow?>) {
		self._nsWindow = nsWindow

		self.controller = controller
		self.screenController = controller.screen()

		self.screenController.bindTo(window: self._nsWindow)
	}

    var body: some View {
		if self.screenController.haveDevice {
			ZStack {
				ScreenViewWrapper(for: self.screenController, isPaused: self.screenController.paused)

				if self.screenController.paused {
					ZStack {
						Color.black.opacity(0.8)

						Text("paused")
							.font(.largeTitle)
					}
				}
			}
		} else {
			ZStack {
				Color.black
				Text("no device selected")
					.multilineTextAlignment(.center)
					.font(.system(size: 16))
					.padding()
			}
			.frame(minWidth: 150, minHeight: 150)
		}
    }
}
