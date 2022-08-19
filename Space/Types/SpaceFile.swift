//
//  FileItem.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

// TODO add reference to annotation
struct SpaceFile: Identifiable, Hashable, Equatable, Comparable {
	var id: Self {self}
	var url: URL
	var isFolder: Bool { self.type == UTType.folder }
	var icon: NSImage
	var type: UTType
	var name: String
	static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.url == rhs.url
	}
	
	static func < (lhs: SpaceFile, rhs: SpaceFile) -> Bool {
		return lhs.name < rhs.name
	}
	
	static func getChildren(url: URL) -> [SpaceFile] {
		do {
			let keys = Array<URLResourceKey>([
				.contentTypeKey,
			])
			var children: [SpaceFile] = []
			for fileUrl in try fm.contentsOfDirectory(
				at: url,
				includingPropertiesForKeys: keys,
				options: .skipsHiddenFiles
			) {
				guard let values = try?
								fileUrl.resourceValues(forKeys: Set<URLResourceKey>([
									.contentTypeKey
								])),
							let contentType = values.contentType
				else {continue}
				if (["plist", "annotation"].contains(fileUrl.pathExtension)) {
					continue
				}
				children.append(SpaceFile(
					url: fileUrl,
					type: contentType
				))
			}
			return children.sorted()
		} catch {
			return []
		}
	}
	
	// TODO rename annotation file at the same time
	func rename(_ newURL: URL) -> Void {
		do {
			try fm.moveItem(
				at: self.url,
				to: newURL)
//			self.url = newURL
		} catch {}
	}
	
	init(url: URL, type: UTType? = nil) {
		self.url = url
		self.type = type
		?? UTType(filenameExtension: url.pathExtension)
		?? UTType.content
		self.icon = ws.icon(for: self.type) // TODO custom icons?
		self.name = url.lastPathComponent
	}
}

