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

struct SidebarFileTree: View {
	var file: FileItem
	@State var isExpanded: Bool = false
	
	var body: some View {
		if file.isFolder {
			DisclosureGroup(
				isExpanded: $isExpanded,
				content: {
					if isExpanded {
						ForEach(FileItem.getChildren(url: file.url), id: \.self.id) { childNode in
							SidebarFileTree(file: childNode)
						}
					}
				},
				label: {
					Image(nsImage: file.icon)
						.resizable(resizingMode: .tile)
						.frame(width: 20, height: 20, alignment: .center)
					Text(file.name).lineLimit(1).frame(alignment: .center)
				})
		}
	}
	
}
