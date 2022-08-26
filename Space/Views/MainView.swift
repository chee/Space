//
//  Main.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI

struct MainView: View {
	@AppStorage("root") private var rootURL: URL?
	@StateObject var appState = SpaceState()
	
	init() {
		while rootURL == nil {
			let panel = NSOpenPanel()
			panel.canChooseFiles = false
			panel.canChooseDirectories = true
			panel.allowsMultipleSelection = false
			if panel.runModal() == .OK {
				rootURL = panel.url
			}
		}
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
			appState.objectWillChange.send()
		}
	}
	
	var body: some View {
		NavigationView {
			List {
				SpaceFileTree(
					folder: $appState.rootFolder,
					selection: $appState.sidebarSelection,
					parent: []
				)
				.environmentObject(appState)
				.onAppear {
					if appState.sidebarSelection == nil {
						appState.sidebarSelection = appState.rootFolder.url
					}
				}
			}
			Text("Select an item in the sidebar")
		}
		.searchable(
			text: $appState.search,
			placement: .toolbar
		)
		.onAppear {
			appState.setRootURL(url: rootURL!)
		}
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
