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
class SpaceFile: ObservableObject, Identifiable, Hashable, Equatable, Comparable {
	static let richTypes: [UTType] = [.rtf, .rtfd, .flatRTFD]
	static let htmlTypes: [UTType] = [.html]
	static let plainTypes: [UTType] = [.plainText]
	
	var id: URL {url}
	var url: URL
	var isFolder: Bool { self.type == UTType.folder }
	var icon: NSImage
	var type: UTType
	var name: String
	
	func hash(into hasher: inout Hasher) {
		return hasher.combine(ObjectIdentifier(self))
	}
	
	static func ==(lhs: SpaceFile, rhs: SpaceFile) -> Bool {
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
	
	func getChildren() -> [SpaceFile] {
		Self.getChildren(url: self.url)
	}
	
	lazy var children = {
		getChildren()
	}()
	
	func find(_ id: ID) -> SpaceFile? {
		if self.id == id {
			return self
		}
		
		for child in children {
			if let match = child.find(id) {
				return match
			}
		}
		
		return nil
	}
	
	lazy var attributedString = { () -> NSAttributedString? in
		do {
			// TODO handle failure
			if (SpaceFile.richTypes.contains(self.type)) {
				return try NSAttributedString(rtfData: contents!)
			} else if (SpaceFile.htmlTypes.contains(type)) {
				// TODO fancier html
				return NSAttributedString(html: contents!, documentAttributes: .none)!
			} else if (SpaceFile.plainTypes.contains(type)) {
				return try NSAttributedString(data: contents!, format: .plainText)
			}
		} catch {
		}
		return nil
	}()
	
	func showInFinder() {
		ws.selectFile(
			url.path,
			inFileViewerRootedAtPath: url.path
		)
	}
	
	func getContents() -> Data? {
		fm.contents(atPath: url.path)
	}
	
	lazy var contents = {
		getContents()
	}()
	
	var annotationURL: URL {
		url.appendingPathExtension("annotation")
	}
	
	var annotationExists: Bool {
		fm.fileExists(atPath: annotationURL.path)
	}
	
	var annotationFile: SpaceFile {
		SpaceFile(url: annotationURL, type: UTType.rtf)
	}
	
	func save() {
		print("saving")
		print(type)
		if Self.richTypes.contains(type) {
			do {
				print("saving rich text")
				let rtf = try attributedString?.richTextRtfData()
				print("writing")
				print(rtf as Any)
				try rtf?.write(to: url)
				print("done")
			} catch {
				print("failed to write file :o")
			}
		} else if Self.htmlTypes.contains(type) {
			let html = attributedString?.asHTML!
			do {
				try html?.data(using: .utf8)?.write(to: url)
			} catch {
				print("failed to write file")
			}
		}
	}
	
	// TODO rename annotation file at the same time
	func rename(_ newURL: URL) -> Void {
		do {
			try fm.moveItem(
				at: self.url,
				to: newURL
			)
			
			if annotationExists {
				try fm.moveItem(
					at: annotationURL,
					to: newURL.appendingPathExtension("annotation")
				)
			}
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

