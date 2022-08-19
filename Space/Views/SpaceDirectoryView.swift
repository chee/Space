//
//  SpaceTableView.swift
//  Space
//
//  Created by chee on 2022-08-17.
//

import SwiftUI
import AppKit
import Foundation

struct SpaceDirectoryView: View {
	let url: URL
	let files: [SpaceFile]
	@State private var selection = Set<SpaceFile>()
	@FocusState private var focusedFile: SpaceFile?
	init(url: URL) {
		self.url = url
		self.files = SpaceFile.getChildren(url: url)
	}
	@State private var choice: SpaceFile?
	
	var body: some View {
		VSplitView {
			List(files, selection: $selection) {file in
				HStack {
					Image(nsImage: file.icon)
						.resizable()
						.frame(width: 22, height: 22, alignment: .leading)
					Text(file.name)
					Spacer()
					Text(file.type.localizedDescription ?? file.type.description)
				}
				.contentShape(Rectangle())
				//			.onDoubleClick {
				//				if choice != nil && focusedFile == nil {
				//					if choice!.isFolder {
				//						context = choice!
				//					} else {
				//						ws.open(choice!.url)
				//					}
				//				}
				//			}
			}
			.onChange(of: selection) {_ in
				choice = nil
				if selection.count == 1 {
					choice = selection.first!
				}
			}
			.listStyle(.bordered(alternatesRowBackgrounds: true))
			if selection.count == 1 {
				DetailView(file: selection.first!)
			} else {
				Text("Select a file").frame(
					maxWidth: .infinity,
					maxHeight: .infinity,
					alignment: .center
				)
			}
		}
	}
}

