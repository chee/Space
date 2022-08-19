//
//  Main.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
	var rootURL: URL
	var rootFile: SpaceFile
	var files: [SpaceFile]
	@State var search = ""
	@State var selection: URL? = nil
	
	init(_ rootURL: URL) {
		self.rootURL = rootURL
		rootFile = SpaceFile(
			url: rootURL,
			type: UTType.folder
		)
		files = rootFile.getChildren()
	}
	
	private func toggleSidebar() {
		NSApp.keyWindow?
			.firstResponder?
			.tryToPerform(#selector(
				NSSplitViewController.toggleSidebar(_:)
			), with: nil)
	}
	
	
//	func createFile() {
//		var folderURL: URL
//		if tableChoice != nil {
//			if tableChoice!.isFolder {
//				folderURL = tableChoice!.url
//			} else {
//				folderURL = tableChoice!.url.deletingLastPathComponent()
//			}
//		} else if sidebarChoice != nil {
//			folderURL = sidebarChoice!.url
//		} else {
//			folderURL = rootURL
//		}
//		let fileURL = folderURL.appendingPathComponent("New File.html")
//		let path = fileURL.path
//		fm.createFile(atPath: path, contents: nil)
//		sidebarChoice = SpaceFile(url: folderURL, type: UTType.folder)
//		tableChoice = SpaceFile(url: fileURL, type: UTType.html)
//	}

	var body: some View {
		NavigationView {
			List(files) {file in
				SpaceFileTree(file: file, isExpanded: true)
			}
			Text("Select a folder in the sidebar")
		}
		.searchable(text: $search, placement: .toolbar)
		.toolbar {
			ToolbarItem(placement: .navigation) {
				Button(action: toggleSidebar) {
					Label("Toggle sidebar", systemImage: "sidebar.left")
				}.keyboardShortcut("\\")
			}
		}
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView(_previewRootURL).preferredColorScheme(.dark)
		MainView(_previewRootURL).preferredColorScheme(.light)
	}
}
