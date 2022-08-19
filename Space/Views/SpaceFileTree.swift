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
	var file: SpaceFile
	@State var isExpanded: Bool = true
	@State var choice: SpaceFile?
	@State var context: SpaceFile?
	
	var body: some View {
		if file.isFolder {
			DisclosureGroup(
				isExpanded: $isExpanded,
				content: {
					if isExpanded {
						ForEach(file.children, id: \.self.id) { childNode in
							SpaceFileTree(file: childNode, isExpanded: false)
						}
					}
				},
				label: {
					NavigationLink(value: file.id) {
						Image(nsImage: file.icon)
							.resizable(resizingMode: .tile)
							.frame(width: 20, height: 20, alignment: .center)
						Text(file.name).lineLimit(1).frame(alignment: .center)
					}
				})
		}
	}
	
}
