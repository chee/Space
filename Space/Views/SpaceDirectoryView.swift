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
	@Binding var selection: SpaceFile.ID?
	@FocusState private var focusedFile: SpaceFile?
	@State private var choice: SpaceFile.ID?
	
	var body: some View {
//		VSplitView {
			List(dir!.children, selection: $selection) {file in
				NavigationLink(value: file.id) {
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
			}
//			.onChange(of: selection) {_ in
//				choice = nil
//				if selection.count == 1 {
//					choice = selection.first!
//				}
//			}
			.listStyle(.bordered(alternatesRowBackgrounds: true))
//			if choice != nil {
//				DetailView(file: dir!.find(choice!)!)
//			} else {
//				Text("Select a file").frame(
//					maxWidth: .infinity,
//					maxHeight: .infinity,
//					alignment: .center
//				)
//			}
		}
	}
//}

