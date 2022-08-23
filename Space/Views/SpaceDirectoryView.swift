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


let defaultDetail = AnyView(Color(.white).frame(maxHeight: .infinity))

struct SpaceDirectoryView: View {
	weak var dir: SpaceFile?
	@State private var selection = Set<SpaceFile.ID>()
	let select: (SpaceFile.ID) -> Void
	@FocusState private var focusedFile: SpaceFile?
	@State var detail: AnyView = defaultDetail
	
	@ViewBuilder
	var body: some View {
		VSplitView {
			List(dir!.children, id: \.id, selection: $selection) {file in
				HStack {
					Image(nsImage: file.icon)
						.resizable()
						.frame(width: 22, height: 22, alignment: .leading)
					Text(file.name)
					Spacer()
					Text(file.type.localizedDescription ?? file.type.description)
				}
				.contentShape(Rectangle())
				.contextMenu {
					Button("Show in Finder", action: file.showInFinder)
						.keyboardShortcut("o", modifiers: [.shift, .command])
				}
			}
			ZStack { detail }.frame(maxHeight: .infinity)
		}
		.onChange(of: selection) {_ in
			self.detail = defaultDetail
			// this causes a little flicker but means we always create a new view which is important for the richtext
			DispatchQueue.main.async {
				if selection.count == 1 {
					self.detail = AnyView(DetailView(file: dir!.find(selection.first!)!))
				}
			}
		}
		.onDoubleClick {
			if let selection = selection.first {
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
	}
}


