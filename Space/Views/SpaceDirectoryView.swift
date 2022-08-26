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
	@ObservedObject var file: SpaceFile
	let select: (SpaceFile.ID) -> Void
	@Binding var selection: Set<SpaceFile.ID>
	@State var isExpanded: Bool = false
	@State var confirming: Bool = false
	
	var body: some View {
		let label = HStack {
			Image(nsImage: file.icon)
				.resizable()
				.frame(width: 22, height: 22, alignment: .leading)
			Text(file.name)
			Spacer()
			Text(file.type.localizedDescription ?? file.type.description)
			
		}	.lineLimit(1)
			.font(.system(size: 18))
			.onDoubleClick {
					if file.isFolder {
						select(file.id)
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
			}
		if file.isFolder {
			DisclosureGroup(isExpanded: $isExpanded, content: {
				if isExpanded {
					ForEach(file.children, id: \.self.id) {child in
						SpaceDirectoryRow(file: child, select: select, selection: $selection)
					}
				}
			}, label: {label})
		} else {
			label
		}
	}
}

struct SpaceDirectoryView: View {
	@ObservedObject var folder: SpaceFile
	let select: (SpaceFile.ID) -> Void
	@State private var selection = Set<SpaceFile.ID>()
	@FocusState private var focusedFile: SpaceFile?
	@State var detail: AnyView = defaultDetail
	
	var body: some View {
		List(folder.children, id: \.id, selection: $selection) {file in
			SpaceDirectoryRow(file: file, select: select, selection: $selection)
		}
		.onChange(of: selection) {_ in
			self.detail = defaultDetail
			if selection.count == 1 {
				let file = folder.find(selection.first!)!
				if TextEditorDetailView.supportedTypes.contains(file.type) {
					// this causes a little flicker but means we always create a new view
					// which is important for the richtext
					DispatchQueue.main.async {
						self.detail = AnyView(DetailView(file: file))
					}
				} else {
					self.detail = AnyView(DetailView(file: file))
				}
			}
		}
		.listStyle(.bordered(alternatesRowBackgrounds: true))
		detail.frame(maxHeight: .infinity)
	}
}


