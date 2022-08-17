//
//  FileItem.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

struct FileItem: Identifiable, Hashable, Equatable, Comparable {
	static func < (lhs: FileItem, rhs: FileItem) -> Bool {
		return lhs.name < rhs.name
	}
	
	var id: Self {self}
	var url: URL
	
	static func getChildren(url: URL) -> [FileItem] {
		do {
			let keys = Array<URLResourceKey>([
				.contentTypeKey,
			])
			var children: [FileItem] = []
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
				children.append(FileItem(
					url: fileUrl,
					type: contentType
				))
			}
			return children.sorted()
		} catch {
			return []
		}
	}
	
	lazy var children: [FileItem] = {
		if _children == nil {
			loadChildren()
		}
		return _children!
	}()

	private var _children: [FileItem]?
	
	mutating func loadChildren() -> Void {
		_children = FileItem.getChildren(url: url).sorted()
	}
	
	lazy var contents: Data = {
		if _contents == nil {
			loadContents()
		}
		return _contents!
	}()
	
	private var _contents: Data?
	
	mutating func loadContents() -> Void {
		_contents = fm.contents(atPath: url.path)
	}
	
	var isFolder: Bool { self.type == UTType.folder }
	var icon: NSImage
	var type: UTType
	var name: String
	
	init(url: URL, type: UTType?) {
		self.url = url
		self.icon = ws.icon(for: type ?? UTType.content) // custom icons?
		self.name = url.lastPathComponent
		self.type = type ?? UTType.content
	}
}

