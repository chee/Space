//
//  NSAttributedString+toHTML.swift
//  Space
//
//  Created by chee on 2022-08-19.
//

import Foundation

extension NSAttributedString {
	public var asHTML: String? {
		let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
		do {
			let htmlData = try data(from: NSMakeRange(0, length), documentAttributes: documentAttributes)
			if let htmlString = String(data: htmlData, encoding: String.Encoding.utf8) {
				return htmlString
			}
		} catch {
			
		}
		return nil
	}
}
