//
//  FileItem.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SpaceFileTree: View {
	weak var file: SpaceFile?
	@Binding var selection: SpaceFile.ID?
	@State var isExpanded: Bool = true
	
	var body: some View {
		if file!.isFolder {
			DisclosureGroup(
				isExpanded: $isExpanded,
				content: {
					if isExpanded {
						ForEach(file!.children, id: \.self.id) { childNode in
							SpaceFileTree(file: childNode, selection: $selection, isExpanded: false)
						}
					}
				},
				label: {
					NavigationLink(
						destination: SpaceDirectoryView(dir: file) {id in
							if file!.find(id) != nil {
								self.isExpanded = true
								// TODO find a better way
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
									selection = id
								}
							}
						},
						tag: file!.id, selection: $selection,
						label: {
							Image(nsImage: file!.icon)
								.resizable(resizingMode: .tile)
								.frame(width: 20, height: 20, alignment: .center)
							Text(file!.name).lineLimit(1).frame(alignment: .center)
						})
				}).onChange(of: selection) {[selection] next in
					if next == nil && selection != nil {
						self.selection = selection
					}
				}
		}
	}
}
