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
	var rootFile: FileItem {
		FileItem(
			url: rootURL,
			type: UTType.folder
		)
	}
	
	@State var sidebarTarget: FileItem?
	@State var tableTarget: FileItem?
	
	var body: some View {
		HSplitView {
			SidebarView(dirs: [rootFile], choice: $sidebarTarget)
			VSplitView {
				FileTable(context: $sidebarTarget, choice: $tableTarget)
				DetailView(file: $tableTarget)
			}
			.frame(minWidth: 400, alignment: .trailing)
		}.toolbar {
			ToolbarItemGroup(placement: .automatic) {
				Spacer()
				Button(action: {
					print("lol, not actually")
				}) {
					Label("Search", systemImage: "magnifyingglass")
				}.keyboardShortcut("f", modifiers: [.shift, .command])
			}
		}.onAppear() {
			sidebarTarget = rootFile
		}
	}
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView(rootURL: _previewRootURL).preferredColorScheme(.dark)
		MainView(rootURL: _previewRootURL).preferredColorScheme(.light)
	}
}
