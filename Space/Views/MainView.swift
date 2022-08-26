//
//  Main.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
	@State var search = ""
	@AppStorage("root") private var rootURL: URL?
	@AppStorage("sidebarSelection") private var sidebarSelection: SpaceFile.ID?
	@ObservedObject var rootFolder: SpaceFile = SpaceFile(folder: "/users/chee/docs/notebook/")
	
	init() {
		if rootURL == nil {
			let panel = NSOpenPanel()
			panel.canChooseFiles = false
			panel.canChooseDirectories = true
			panel.allowsMultipleSelection = false
			if panel.runModal() == .OK {
				rootURL = panel.url
			}
		}
		rootFolder = SpaceFile(
			url: rootURL!,
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
	
	private func reload() {
		DispatchQueue.main.sync {
			rootFolder.objectWillChange.send()
		}
	}
	
	var body: some View {
		NavigationView {
			List {
				SpaceFileTree(
					folder: rootFolder,
					selection: $sidebarSelection,
					isExpanded: true,
					parent: []
				).environmentObject(rootFolder)
				.onAppear {
					if sidebarSelection == nil {
						sidebarSelection = rootFolder.id
					}
				}
			}
			Text("Select an item in the sidebar")
		}
		.searchable(text: $search, placement: .toolbar)
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
			.preferredColorScheme(.dark)
		MainView()
			.preferredColorScheme(.light)
	}
}
