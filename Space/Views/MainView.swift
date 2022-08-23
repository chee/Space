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
	@State var search = ""
	
	init(_ rootURL: URL) {
		self.rootURL = rootURL
		rootFile = SpaceFile(
			url: rootURL,
			type: UTType.folder
		)
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
	@State private var sidebarSelection: SpaceFile.ID?
	@State private var listSelection: SpaceFile.ID?
	
	var body: some View {
		NavigationView {
			List([rootFile]) {file in
				SpaceFileTree(
					file: file,
					selection: $sidebarSelection,
					isExpanded: true
				).onAppear {
					sidebarSelection = rootFile.id
				}
			}
			Text("Select an item in the sidebar")
		}
		.searchable(text: $search, placement: .toolbar)
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView(_previewRootURL).preferredColorScheme(.dark)
		MainView(_previewRootURL).preferredColorScheme(.light)
	}
}
