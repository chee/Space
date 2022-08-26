//
//  SpaceTableView.swift
//  Space
//
//  Created by chee on 2022-08-17.
//

import SwiftUI
import AppKit
import Foundation

let defaultDetail = AnyView(Color(.clear).frame(maxHeight: .infinity))

struct SpaceDirectoryRow: View {
	var file: SpaceFile
	@Binding var selection: Set<URL>
	@State var isExpanded: Bool = false
	@State var confirming: Bool = false
	@EnvironmentObject var appState: SpaceState
	@State private var renaming = false
	@FocusState private var focused: Bool
	@State private var newName = ""
	
	func startRenaming() {
		renaming = true
		newName = file.name
		focused = true
	}
	
	func rename(to newURL: URL) {
		appState.move(from: file.url, to: newURL)
		focused = false
		newName = ""
		selection.removeAll()
		//		file.url = newURL
	}
	
	func quitRenaming() {
		focused = false
		renaming = false
		if selection.isEmpty {
			selection.insert(file.url)
		}
	}
	
	var body: some View {
		let label = HStack {
			Image(nsImage: file.icon)
				.resizable()
				.frame(width: 22, height: 22, alignment: .leading)
			if renaming {
				TextField(file.name, text: $newName)
					.focused($focused, equals: true)
					.frame(alignment: .leading)
					.onSubmit {
						let newURL = file.url.deletingLastPathComponent()
							.appendingPathComponent(newName)
						self.rename(to: newURL)
						//						selection.removeAll()
						//						selection.insert(newURL)
					}
					.onChange(of: focused) {state in
						if state == false {
							quitRenaming()
						}
					}
			} else {
				Text(file.name)
			}
			Spacer()
			Text(file.type.localizedDescription ?? file.type.description)
			Text("move")
		}
			.lineLimit(1)
			.font(.system(size: 18))
			.onDoubleClick {
				if file.isFolder {
					appState.openInSidebar(file.url)
				} else {
					ws.open(file.url)
				}
			}
			.contentShape(Rectangle())
			.contextMenu {
				Button("Show in Finder", action: file.showInFinder)
					.keyboardShortcut("o", modifiers: [.shift, .command])
				Button("Add annotation", action: file.createAnnotation)
					.keyboardShortcut(.return, modifiers: [.option])
				Button("Remove annotation", action: file.removeAnnotation)
					.keyboardShortcut(.delete, modifiers: [.option])
				Button("Rename", action: startRenaming)
					.keyboardShortcut(.defaultAction)
			}
		if file.isFolder {
			DisclosureGroup(isExpanded: $isExpanded, content: {
				if isExpanded {
					ForEach(file.getChildren(), id: \.self.url) {child in
						SpaceDirectoryRow(file: child, selection: $selection)
					}
				}
			}, label: {label})
		} else {
			label
		}
	}
}

struct SpaceDirectoryView: View {
	@Binding var folder: SpaceFile
	@State private var selection = Set<URL>()
	@EnvironmentObject var appState: SpaceState
	@FocusState private var focusedFile: SpaceFile?
	@State var detail: AnyView = defaultDetail
	
	var body: some View {
		VSplitView {
			List(folder.getChildren(), id: \.url, selection: $selection) {file in
				SpaceDirectoryRow(file: file, selection: $selection)
					.environmentObject(appState)
			}
			.onChange(of: selection) {_ in
				self.detail = defaultDetail
				if selection.count == 1 {
					let file = SpaceFile(url: selection.first!)
					// this causes a little flicker but means we always create a new view
					// which is important for the richtext
					DispatchQueue.main.async {
						self.detail = AnyView(
							DetailView(file: file)
								.environmentObject(appState)
						)
					}
				}
			}
			.listStyle(.bordered(alternatesRowBackgrounds: true))
			detail.frame(maxHeight: .infinity)
		}
	}
}
