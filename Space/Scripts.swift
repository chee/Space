//
//  Scripts.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import Foundation
import Cocoa

class SendCommand: NSScriptCommand {
	override func performDefaultImplementation() -> Any? {
		let message = self.evaluatedArguments!["message"] as! String
		print("they said \(message)");
		return message
	}
}
