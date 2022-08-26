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
	static let videoTypes: [UTType] = [.movie]
	
	var id: URL {url}
	var url: URL
	var isFolder: Bool { self.type == UTType.folder }
	var icon: NSImage
	var type: UTType
	var name: String
	var accessedOn: Date? = nil
	var createdOn: Date? = nil
	var modifiedOn: Date? = nil
	
	init(url: URL, type: UTType? = nil) {
		self.url = url
		self.type = type
		?? UTType(filenameExtension: url.pathExtension)
		?? UTType.content
		self.name = url.lastPathComponent
		self.icon = ws.icon(forFile: url.path)
		do {
			let data = try url.resourceValues(forKeys: [
				.contentAccessDateKey,
				.creationDateKey,
				.contentModificationDateKey,
			])
			self.accessedOn = data.contentAccessDate
			self.createdOn = data.creationDate
			self.modifiedOn = data.contentModificationDate
		} catch {
			// ok
		}
	}

	convenience init(_ path: String) {
		self.init(
			url: URL(fileURLWithPath: path)
				.resolvingSymlinksInPath()
		)
	}
	
	convenience init(folder: String) {
		self.init(
			url: URL(fileURLWithPath: folder)
				.resolvingSymlinksInPath(),
			type: UTType.folder
		)
	}
	
	func hash(into hasher: inout Hasher) {
		return hasher.combine(ObjectIdentifier(self))
	}
	
	static func ==(lhs: SpaceFile, rhs: SpaceFile) -> Bool {
		lhs.url == rhs.url
	}
	
	static func < (lhs: SpaceFile, rhs: SpaceFile) -> Bool {
		lhs.name < rhs.name
	}
	
	func getChildren() -> [SpaceFile] {
		print("looking at children \(url)")
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
				guard let values = try? fileUrl.resourceValues(forKeys: Set<URLResourceKey>([
					.contentTypeKey
				])), let contentType = values.contentType
				else {continue}
				if (["plist", "annotation"].contains(fileUrl.pathExtension)) {
					continue
				}
				children.append(SpaceFile(
					url: fileUrl,
					type: contentType
				))
			}
			return children.sorted {
				if $0.isFolder && !$1.isFolder {
					return true
				} else if $1.isFolder && !$0.isFolder {
					return false
				} else {
					return $0 < $1
				}
			}
		} catch {
			return []
		}
	}
	
	lazy var children: [SpaceFile] = {
		if _children == nil {
			_children = getChildren()
		}
		return getChildren()
	}()

	@Published var _children: [SpaceFile]?
	
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
	
	func conforms(to types: [UTType]) -> Bool {
		for foreign in types {
			if type.conforms(to: foreign) {
				return true
			}
		}
		return false
	}
	
	lazy var attributedString = { () -> NSAttributedString in
		do {
			// TODO handle failure
			if (conforms(to: Self.richTypes)) {
				return try NSAttributedString(rtfData: contents!)
			} else if (conforms(to: Self.htmlTypes)) {
				// TODO fancier html
				return NSAttributedString(html: contents!, documentAttributes: .none)!
			} else if (conforms(to: Self.plainTypes)) {
				return try NSAttributedString(data: contents!, format: .plainText)
			}
		} catch {
		}
		return NSAttributedString(string: "")
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
	
	var exists: Bool {
		fm.fileExists(atPath: url.path)
	}
	
	var annotationFile: SpaceFile {
		SpaceFile(url: annotationURL, type: UTType.rtf)
	}
	
	func createAnnotation() -> Void {
		if !annotationExists {
			fm.createFile(atPath: annotationURL.path, contents: Data())
		}
		objectWillChange.send()
	}
	
	func removeAnnotation() -> Void {
		if annotationExists {
			do {
				try fm.trashItem(at: annotationURL, resultingItemURL: nil)
			} catch {}
		}
		objectWillChange.send()
	}
	
	func save() {
		if !exists {
			return
		}
		if Self.richTypes.contains(type) {
			do {
				let rtf = try attributedString.richTextRtfData()
				try rtf.write(to: url)
			} catch {
				print("failed to write file :o")
			}
		} else if Self.htmlTypes.contains(type) {
			let html = attributedString.asHTML!
			do {
				try html.data(using: .utf8)?.write(to: url)
			} catch {
				print("failed to write file")
			}
		}
	}
	
	func drop(_ dropped: SpaceFile) -> Void {
		dropped.move(
			self.url.appendingPathComponent(
				dropped.url.lastPathComponent
			)
		)
		DispatchQueue.main.async {
			self._children = nil
		}
	}
	
	func move(_ newURL: URL) -> Void {
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
}

