//
//  SpaceTableView.swift
//  Space
//
//  Created by chee on 2022-08-17.
//

import SwiftUI
import AppKit
import Foundation

struct SpaceFileTable: View {
	@State private var selection = Set<FileItem>()
	@Binding var context: FileItem?
	@Binding var choice: FileItem?
	var openDirectory: (FileItem) -> Void
	@State private var sortOrder = [KeyPathComparator(\FileItem.name)]
	@State private var files: [FileItem]?
	var body: some View {
		if let items = files {
			List(items, selection: $selection) {file in
				HStack {
					Image(nsImage: file.icon)
						.resizable()
						.frame(width: 22, height: 22, alignment: .leading)
					Text(file.name).frame(alignment: .leading)
					Text(file.type.identifier)
					Spacer()
				}
				.contentShape(Rectangle())
				.onDoubleClick {
					if selection.count == 1 {
						ws.open(selection.first!.url)
					}
				}
			}
		}
		Group{}
			.onChange(of: context) {newContext in
				selection.removeAll()
				choice = nil
				files = nil
				if newContext != nil {
					files = context!.children
						.sorted(using: sortOrder)
						.filter {
							$0.url.pathExtension != "annotation"
						}
				}
			}
			.onChange(of: selection) {selected in
				choice = nil
				if selected.count == 1 {
					choice = selected.first!
				}
			}
			.onChange(of: choice) {chosen in
				if chosen != nil && selection.count == 0 {
					selection.insert(chosen!)
				}
			}
	}
}

