//
//  SpaceTableView.swift
//  Space
//
//  Created by chee on 2022-08-17.
//

import SwiftUI
import AppKit
import Foundation
//
//struct SpaceDirectoryRow: View {
//	weak var file: SpaceFile?
//	@Binding var selection: SpaceFile.ID?
//	@State var isExpanded: Bool = true
//
//	var body: some View {
//		if let file = file {
//			if file.isFolder {
//				DisclosureGroup(
//					isExpanded: $isExpanded,
//					content: {
//						if isExpanded {
//							ForEach(file.children, id: \.self.id) { childNode in
//								SpaceDirectoryRow(file: childNode, selection: $selection)
//							}
//						}
//					}, label: {
//						Image(nsImage: file.icon)
//							.resizable()
//							.frame(width: 22, height: 22, alignment: .leading)
//						Text(file.name)
//						Spacer()
//						Text(file.type.localizedDescription ?? file.type.description)
//					})
//			} else {
//
//			}
//		}
//	}
//}

struct SpaceDirectoryView: View {
	weak var dir: SpaceFile?
	@State private var selection = Set<SpaceFile.ID?>()
	let select: (SpaceFile.ID) -> Void
	@FocusState private var focusedFile: SpaceFile?
	@State private var choice: SpaceFile.ID?
	
	var body: some View {
		NavigationView {
			List(dir!.children, selection: $selection) {file in
				NavigationLink(
					destination: DetailView(file: dir!.find(file.id)!),
					label: {
						HStack {
							Image(nsImage: file.icon)
								.resizable()
								.frame(width: 22, height: 22, alignment: .leading)
							Text(file.name)
							Spacer()
							Text(file.type.localizedDescription ?? file.type.description)
						}
						.contentShape(Rectangle())
					}
				)
				.contextMenu {
					Button("Show in Finder", action: file.showInFinder)
						.keyboardShortcut("o", modifiers: [.shift, .command])
				}
			}
			.onDoubleClick {
				if let selection = selection.first, let selection = selection {
					let target = dir?.find(selection)
					if let target = target {
						if target.isFolder {
							select(target.id)
						} else {
							ws.open(target.url)
						}
					}
				}
			}
			.listStyle(.bordered(alternatesRowBackgrounds: true))
			
//			if selection != nil {
//
//			} else {
//				Text("Select a file").frame(
//					maxWidth: .infinity,
//					maxHeight: .infinity,
//					alignment: .center
//				)
//			}
		}
	}
}

