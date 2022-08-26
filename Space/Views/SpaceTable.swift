//
//  SpaceTableView.swift
//  Space
//
//  Created by chee on 2022-08-17.
//

import SwiftUI
import AppKit
import Foundation
import UniformTypeIdentifiers

let defaultDetail = AnyView(Color(.clear).frame(maxHeight: .infinity))

struct SpaceTableRow: View {
	var file: SpaceFile
	@State var isExpanded: Bool = false
	@State var confirming: Bool = false
	@EnvironmentObject var appState: SpaceState
	@State private var renaming = false
	@FocusState private var focused: Bool
	@State private var newName = ""

	func isExpanded(_ url: URL) -> Binding<Bool> {
		return .init(
			get: { appState.isExpandedInTable[url, default: false] },
			set: { appState.isExpandedInTable[url] = $0 }
		)
	}
	
	func startRenaming() {
		renaming = true
		newName = file.name
		focused = true
	}
	
	func rename(to newURL: URL) {
		appState.move(from: file.url, to: newURL)
		focused = false
		newName = ""
		appState.tableSelection.removeAll()
		//		file.url = newURL
	}
	
	func quitRenaming() {
		focused = false
		renaming = false
		if appState.tableSelection.isEmpty {
			appState.tableSelection.insert(file.url)
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
				Button("Show in Finder", action: {appState.showInFinder(file)})
					.keyboardShortcut("o", modifiers: [.shift, .command])
				Button("Add annotation", action: {appState.createAnnotation(for: file)})
					.keyboardShortcut(.return, modifiers: [.option])
				Button("Remove annotation", action: {appState.removeAnnotation(for: file)})
					.keyboardShortcut(.delete, modifiers: [.option])
				Button("Rename", action: startRenaming)
					.keyboardShortcut(.defaultAction)
			}
		if file.isFolder {
			DisclosureGroup(isExpanded: $isExpanded, content: {
				if isExpanded {
					ForEach(file.getChildren(), id: \.self.url) {child in
						SpaceTableRow(file: child)
					}
				}
			}, label: {label})
		} else {
			label
		}
	}
}

struct SpaceTable: View {
	@Binding var folder: SpaceFile
	@EnvironmentObject var appState: SpaceState
	@FocusState private var focusedFile: SpaceFile?
	@State var detail: AnyView = defaultDetail
	
	var body: some View {
		VSplitView {
			List(folder.getChildren(), id: \.url, selection: $appState.tableSelection) {file in
				SpaceTableRow(file: file)
					.environmentObject(appState)
			}
			.toolbar {
				ToolbarItemGroup(placement: .primaryAction) {
					Button(action: {appState.tableTrashSelection()}) {
						Label("Delete", systemImage: "delete.backward.fill")
					}.keyboardShortcut(.delete)
					Button(action: {appState.tableCreateFile(fallback: folder.url)}) {
						Label("New file", systemImage: "doc.fill.badge.plus")
					}.keyboardShortcut("n")
				}
			}
			.onChange(of: appState.tableSelection) {_ in
				self.detail = defaultDetail
				if appState.tableSelection.count == 1 {
					let file = SpaceFile(url: appState.tableSelection.first!)
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
