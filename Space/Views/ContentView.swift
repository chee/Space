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
		.searchable(
			text: $appState.search,
			placement: .toolbar
		)
		.handlesExternalEvents(preferring: Set(arrayLiteral: "*"), allowing: Set(arrayLiteral: "*"))
		.onOpenURL {url in
			appState.setTargetURL(url)
		}
	}
}
