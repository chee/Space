//
//  Binding+onChange.swift
//  Space
//
//  Created by chee on 2022-08-18.
//

import Foundation
import SwiftUI

extension Binding {
	func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
		Binding(
			get: { self.wrappedValue },
			set: { newValue in
				self.wrappedValue = newValue
				handler(newValue)
			}
		)
	}
}
