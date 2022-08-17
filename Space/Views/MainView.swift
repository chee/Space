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
	var rootFile: FileItem
	var children: [FileItem]
	
	init(_ rootURL: URL) {
		self.rootURL = rootURL
		rootFile = FileItem(
			url: rootURL,
			type: UTType.folder
		)
		children = rootFile.children
	}
	
	func setSidebarTarget(_ target: FileItem) {
		sidebarTarget = target
	}
	

	@State var sidebarTarget: FileItem?
	@State var tableTarget: FileItem?
	@State var sidebarVisible: Bool = true
	@State var detailVisible: Bool = true
	@State var tableVisible: Bool = true
	
	private func toggleSidebar() {
		NSApp.keyWindow?
			.firstResponder?
			.tryToPerform(#selector(
				NSSplitViewController.toggleSidebar(_:)
			), with: nil)
	}
	
	func toggleDetail() {
		detailVisible = !detailVisible
	}
	
	func toggleTable() {
		tableVisible = !tableVisible
		toggleDetail()
		toggleDetail()
	}
	
	func createFile() {
		var folderURL: URL
		if tableTarget != nil {
			if tableTarget!.isFolder {
				folderURL = tableTarget!.url
			} else {
				folderURL = tableTarget!.url.deletingLastPathComponent()
			}
		} else if sidebarTarget != nil {
			folderURL = sidebarTarget!.url
		} else {
			folderURL = rootURL
		}
		let fileURL = folderURL.appendingPathComponent("New File.html")
		let path = fileURL.path
		fm.createFile(atPath: path, contents: nil)
		sidebarTarget = FileItem(url: folderURL, type: UTType.folder)
		tableTarget = FileItem(url: fileURL, type: UTType.html)
	}
	
	var body: some View {
		NavigationView {
			SidebarView(dirs: children, choice: $sidebarTarget)
				.listStyle(.sidebar)
			VSplitView {
				SpaceFileTable(
					context: $sidebarTarget,
					choice: $tableTarget,
					openDirectory: setSidebarTarget
				).listStyle(.plain)
				DetailView(file: $tableTarget).background()
			}
			.frame(minWidth: 400, alignment: .trailing)
		}
		.toolbar {
			ToolbarItem(placement: .automatic) {
				Button(action: {
					print("lol, not actually")
				}) {
					Label("Search", systemImage: "magnifyingglass")
				}.keyboardShortcut("f", modifiers: [.shift, .command])
			}
			ToolbarItem(placement: .navigation) {
				Button(action: toggleSidebar) {
					Label("Toggle sidebar", systemImage: "sidebar.left")
				}.keyboardShortcut("\\")
			}
//			ToolbarItem(placement: .navigation) {
//				Button(action: toggleTable) {
//					Label("Toggle table", systemImage: "tablecells")
//				}.keyboardShortcut("'")
//			}
//			ToolbarItem(placement: .navigation) {
//				Button(action: toggleDetail) {
//					Label("Toggle detail view", systemImage: "rectangle.bottomhalf.filled")
//				}.keyboardShortcut(";")
//			}
			ToolbarItem(placement: .navigation) {
				Button(action: createFile) {
					Label("New file", systemImage: "square.and.pencil")
				}.keyboardShortcut("n")
			}
		}
		.onAppear() {
			sidebarTarget = children.first!
		}
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView(_previewRootURL).preferredColorScheme(.dark)
		MainView(_previewRootURL).preferredColorScheme(.light)
	}
}
