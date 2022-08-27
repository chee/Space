//
//  SpaceState.swift
//  Space
//
//  Created by chee on 2022-08-26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import AVKit

@MainActor
final class SpaceState: ObservableObject {
	@AppStorage("root") var rootURL: URL?
	@Published var rootFolder: SpaceFile = SpaceFile(folder: "/Users/chee/Documents/Notebooks/")
	@AppStorage("sidebarSelection") var sidebarSelection: URL?
	@Published var tableSelection: Set<URL> = Set()
	@Published var search = ""
	@Published var expandedInSidebar: [URL:Bool] = [:]
	@Published var expandedInTable: [URL:Bool] = [:]
	@Published var texts: [URL:NSAttributedString] = [:]
	@Published var setMediaTime: CMTime? = nil
	@Published var playingMediaTime: CMTime = CMTime()
	
	func chooseDocument() -> URL {
		var url: URL?
		while url == nil {
			let panel = NSOpenPanel()
			panel.canChooseFiles = false
			panel.canChooseDirectories = true
			panel.allowsMultipleSelection = false
			if panel.runModal() == .OK {
				url = panel.url
			}
		}
		return url!
	}
	
	func setRootURL(url: URL?) {
		var u = url
		if u == nil {
			u = chooseDocument()
		}
		rootURL = u!
		rootFolder = SpaceFile(
			url: u!,
			type: UTType.folder
		)
		expandedInSidebar[u!] = true
	}
	
	func setTargetURL(_ url: URL) {
		let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
		if var comps = comps {
			let query = comps.queryItems ?? []
			comps.query = ""
			comps.scheme = "file"
			var u = comps.url!.resolvingSymlinksInPath()
			var time: CMTime? = nil
			for q in query {
				if q.name == "time" {
					if let value = q.value {
						let sex = Double(value)
						if let sex = sex {
							time = CMTime(
								seconds: sex,
								preferredTimescale: .max
							)
						}
					}
				}
			}
			setMediaTime = nil
			let ts = u
			let ss = u.deletingLastPathComponent()
			while u.pathComponents.count > 1 && u != rootURL {
				u.deleteLastPathComponent()
				expandedInSidebar[u] = true
			}
			sidebarSelection = ss
			DispatchQueue.main.async {
				self.tableSelection.removeAll()
				self.tableSelection.insert(ts)
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					self.setMediaTime = time
				}
			}
		}
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
			expandedInSidebar[f] = true
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
	
	func createFolder(at url: URL) -> URL {
		var fileURL = url
			.appendingPathComponent("New Folder")
		var counter = 1
		while fm.fileExists(atPath: fileURL.path) {
			fileURL = fileURL
				.deletingLastPathComponent()
				.appendingPathComponent("New Folder \(counter)")
			counter += 1
		}
		do {
			try fm.createDirectory(at: fileURL, withIntermediateDirectories: true)
		} catch {}
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
		DispatchQueue.main.async {
			self.objectWillChange.send()
		}
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
	
	func tableCreateFile (fallback: URL, type: UTType) {
		let focus = tableSelection.first ?? fallback
		tableSelection.removeAll()
		let newFile = createFile(
			at: focus.hasDirectoryPath
			? focus
			: focus.deletingLastPathComponent(),
			type: type
		)
		tableSelection.insert(newFile)
	}
	
	func tableCreateFolder (fallback: URL) {
		let focus = tableSelection.first ?? fallback
		tableSelection.removeAll()
		let newFolder = createFolder(
			at: focus.hasDirectoryPath
			? focus
			: focus.deletingLastPathComponent()
		)
		tableSelection.insert(newFolder)
	}
}
