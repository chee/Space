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
	@State var isExpanded: Bool = false
	@State var choice: SpaceFile?
	@State var context: SpaceFile?
	@State var selection: URL? = nil
	
	var body: some View {
		if file.isFolder {
			DisclosureGroup(
				isExpanded: $isExpanded,
				content: {
					if isExpanded {
						ForEach(SpaceFile.getChildren(url: file.url), id: \.self.id) { childNode in
							SpaceFileTree(file: childNode, isExpanded: false)
						}
					}
				},
				label: {
					NavigationLink(destination: SpaceDirectoryView(url: file.url)) {
						Image(nsImage: file.icon)
							.resizable(resizingMode: .tile)
							.frame(width: 20, height: 20, alignment: .center)
						Text(file.name).lineLimit(1).frame(alignment: .center)
					}
				})
		}
	}
	
}
