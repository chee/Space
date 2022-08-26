//
//  SpaceState.swift
//  Space
//
//  Created by chee on 2022-08-26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class SpaceState: ObservableObject {
	@AppStorage("root") var rootURL: URL?
	@Published var rootFolder: SpaceFile = SpaceFile(folder: "/Users/chee/Documents/Notebooks/")
	@AppStorage("sidebarSelection") var sidebarSelection: URL?
	@Published var tableSelection: Set<URL> = Set()
	@Published var search = ""
	@Published var isExpandedInSidebar: [URL:Bool] = [:]
	@Published var isExpandedInTable: [URL:Bool] = [:]
	@Published var texts: [URL:NSAttributedString] = [:]
	
	func setRootURL(url: URL) {
		rootURL = url
		rootFolder = SpaceFile(
			url: url,
			type: UTType.folder
		)
		isExpandedInSidebar[url] = true
	}
	
	func drop(to: URL, from: URL) -> Void {
		move(
			from: from,
			to: to.appendingPathComponent(
				from.lastPathComponent
			)
		)
	}

	func openInSidebar(_ url: URL) -> Void {
		sidebarSelection = url
		var f = url
		while f != rootURL && f.pathComponents.count > 1 {
			f = f.deletingLastPathComponent()
			isExpandedInSidebar[f] = true
		}
	}
	
	func createFile(at url: URL, type: UTType) -> URL {
		var fileURL = url
			.appendingPathComponent("New File")
			.appendingPathExtension(for: type)
		var counter = 1
		while fm.fileExists(atPath: fileURL.path) {
			fileURL = fileURL
				.deletingLastPathComponent()
				.appendingPathComponent("New File \(counter)")
				.appendingPathExtension(for: type)
			counter += 1
		}
		fm.createFile(atPath: fileURL.path, contents: Data())
		return fileURL
	}
}


// MARK: - SpaceState+File -
extension SpaceState {
	func createAnnotation(for file: SpaceFile) -> Void {
		if !annotationExists(for: file) {
			fm.createFile(atPath: file.annotationURL.path, contents: Data())
		}
	}
	
	func removeAnnotation(for file: SpaceFile) -> Void {
		if !annotationExists(for: file) {
			do {
				try fm.trashItem(at: file.annotationURL, resultingItemURL: nil)
			} catch {}
		}
	}
	
	func move(from: URL, to: URL) -> Void {
		do {
			try fm.moveItem(
				at: from,
				to: to
			)
			
			let fromFile = SpaceFile(url: from)
			
			if fromFile.annotationExists {
				try fm.moveItem(
					at: fromFile.annotationURL,
					to: to
						.appendingPathExtension("annotation")
				)
			}
		} catch {}
		objectWillChange.send()
	}
	
	func showInFinder(_ file: SpaceFile) {
		ws.selectFile(
			file.url.path,
			inFileViewerRootedAtPath: file.url.path
		)
	}
	
	func annotationExists(for file: SpaceFile) -> Bool {
		return file.annotationExists
	}
	
	func annotationFile(for file: SpaceFile) -> SpaceFile {
		return SpaceFile(url: file.annotationURL, type: UTType.rtf)
	}
	
	func trashURL(_ url: URL) {
		do {
			try fm.trashItem(at: url, resultingItemURL: nil)
			try fm.trashItem(at: url.appendingPathExtension("annotation"), resultingItemURL: nil)
		} catch {}
		objectWillChange.send()
	}
	
	func trashFile(_ file: SpaceFile) {
		trashURL(file.url)
	}
}

// MARK: - SpaceState+Table -
extension SpaceState {
	func tableTrashSelection() {
		for item in tableSelection {
			trashURL(item)
		}
	}
	func tableCreateFile (fallback: URL) {
		let focus = tableSelection.first ?? fallback
		tableSelection.removeAll()
		let newFile = createFile(
			at: focus.hasDirectoryPath
			? focus
			: focus.deletingLastPathComponent(),
			type: UTType.html
		)
		tableSelection.insert(newFile)
	}
}
