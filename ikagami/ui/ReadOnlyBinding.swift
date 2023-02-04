//
//  ReadOnlyBinding.swift
//  ikagami
//
//  Created by zhiayang on 3/2/23.
//

import SwiftUI
import Foundation

func readOnlyBinding<T>(_ getter: @escaping () -> T) -> Binding<T> {
	return Binding(get: getter, set: { _ in })
}
