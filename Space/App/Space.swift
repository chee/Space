//
//  SpaceApp.swift
//  Space
//
//  Created by chee on 2022-08-11.
//

import SwiftUI
import UniformTypeIdentifiers

let ws = NSWorkspace.shared
let fm = FileManager.default
let fnt = NSFontManager.shared
let app = NSApplication.shared

let _previewRootURL = URL(
	fileURLWithPath: "/Users/chee/Documents/Notebooks/"
).resolvingSymlinksInPath()

var _previewRootFile = SpaceFile(
	url: _previewRootURL
)

@main
struct Space: App {
	@ObservedObject var appState = SpaceState()
	@State var pickingRoot = false
	
	init() {
		appState.setRootURL(url: appState.rootURL)
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(appState)
		}
		//.windowStyle(.hiddenTitleBar)
		//.windowToolbarStyle(.unified)
		.commands {
			SidebarCommands()
			TextEditingCommands()
			TextFormattingCommands()
			ToolbarCommands()
			ImportFromDevicesCommands()
		}
		.windowStyle(.titleBar)
		.windowToolbarStyle(.unified(showsTitle: false))
		Settings {
			Form {
				Section("Folder") {
					Text("Current: \(appState.rootURL!.path)")
					Button("Choose Space folder") {
						appState.setRootURL(url: appState.chooseDocument())
					}
				}
			}
			.padding()
		}
	}
}
