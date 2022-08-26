//
//  Main.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var appState: SpaceState

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
				SpaceSidebar(
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
		.onAppear {
			var url = appState.rootURL
			while url == nil {
				let panel = NSOpenPanel()
				panel.canChooseFiles = false
				panel.canChooseDirectories = true
				panel.allowsMultipleSelection = false
				if panel.runModal() == .OK {
					url = panel.url
				}
			}
			appState.setRootURL(url: url!)
		}
		.searchable(
			text: $appState.search,
			placement: .toolbar
		)
		.onOpenURL {url in
			let alert = NSAlert()
			alert.messageText = url.path
			alert.informativeText = url.path
			alert.alertStyle = NSAlert.Style.warning
			alert.addButton(withTitle: "OK")
			alert.addButton(withTitle: "Cancel")
			alert.runModal()
			appState.setRootURL(url: url)
		}
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.preferredColorScheme(.dark)
		ContentView()
			.preferredColorScheme(.light)
	}
}
