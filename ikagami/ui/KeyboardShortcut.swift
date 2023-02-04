//
//  KeyboardShortcut.swift
//  ikagami
//
//  Created by zhiayang on 3/2/23.
//

import SwiftUI
import Foundation

struct ShortcutMaker : View {

	let shortcuts: [Character]
	let action: () -> Void

	var body: some View {
		ZStack {
			ForEach(self.shortcuts, id: \.self) { key in
				Button(action: self.action) {
					EmptyView()
				}
				.keyboardShortcut(KeyEquivalent(key), modifiers: [])
				.buttonStyle(.borderless)
				.fixedSize()
				.frame(width: 0.0, height: 0.0)
				.padding(0)
				.clipped()
				.hidden()
			}
		}
		.fixedSize()
		.frame(width: 0.0, height: 0.0)
		.padding(0)
		.clipped()
		.hidden()
	}
}
