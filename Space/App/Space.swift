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
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.windowStyle(.hiddenTitleBar)
		.windowToolbarStyle(.unified)
		.commands {
			SidebarCommands()
			TextEditingCommands()
			TextFormattingCommands()
			ToolbarCommands()
			ImportFromDevicesCommands()
		}
	}
}
