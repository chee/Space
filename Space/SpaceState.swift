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
	private var rootURL: URL?
	@Published var rootFolder: SpaceFile = SpaceFile(folder: "/Users/chee/Documents/Notebooks/")
	@AppStorage("sidebarSelection") var sidebarSelection: URL?
	@Published var search = ""
	@Published var isExpandedInSidebar: [URL:Bool] = [:]
	@Published var texts: [URL:NSAttributedString] = [:]
	
	func setRootURL(url: URL) {
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
	
	func openInSidebar(_ url: URL) -> Void {
		sidebarSelection = url
		var f = url
		while f != rootURL && f.pathComponents.count > 1 {
			f = f.deletingLastPathComponent()
			isExpandedInSidebar[f] = true
		}
	}
	
	func annotationExists(for file: SpaceFile) -> Bool {
		return file.annotationExists
	}
	
	func annotationFile(for file: SpaceFile) -> SpaceFile {
		return SpaceFile(url: file.annotationURL, type: UTType.rtf)
	}
	
}
