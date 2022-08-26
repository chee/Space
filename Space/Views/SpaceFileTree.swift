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
import XCTest

struct SpaceFileTree: View {
	var folder: SpaceFile
	@EnvironmentObject var rootFolder: SpaceFile
	@Binding var selection: SpaceFile.ID?
	@State var isExpanded: Bool = true
	var parent: [SpaceFileTree]
	
	var body: some View {
		if folder.isFolder {
			DisclosureGroup(
				isExpanded: $isExpanded,
				content: {
					if isExpanded {
						ForEach(folder.children, id: \.self.id) {childFolder in
							SpaceFileTree(
								folder: childFolder,
								selection: $selection,
								isExpanded: false,
								parent: [self]
							)
						}
					}
				},
				label: {
					NavigationLink(
						destination: SpaceDirectoryView(folder: folder) { id in
							if folder.find(id) != nil {
								self.isExpanded = true
								selection = id
								var p = self.parent.first
								while p != nil {
									p?.isExpanded = true
									p = p?.parent.first
								}
							}
						},
						tag: folder.id, selection: $selection,
						label: {
							HStack {
								Image(nsImage: folder.icon)
									.resizable(resizingMode: .stretch)
									.frame(width: 24, height: 24, alignment: .leading)
									.onDrag {
										return NSItemProvider(object: folder.url as NSURL)
									} preview: {
										VStack {
											Image(nsImage: folder.icon)
												.resizable(resizingMode: .stretch)
												.frame(width: 24, height: 24, alignment: .leading)
											Text(folder.name)
												.lineLimit(1)
										}
										.frame(width: 500, height: 500, alignment: .center)
									}
								Text(folder.name)
									.lineLimit(1)
									.font(.system(size: 18))
									.frame(alignment: .center)
							}
						})
					.contextMenu {
						Button("Show in Finder", action: folder.showInFinder)
							.keyboardShortcut("o", modifiers: [.shift, .command])
					}
					.onDrop(of: ["public.file-url"], isTargeted: nil) { (drops) -> Bool in
						for drop in drops {
							drop.loadItem(forTypeIdentifier: "public.file-url") { (data, error) in
								let url = NSURL(
									absoluteURLWithDataRepresentation: data as! Data,
									relativeTo: nil
								) as URL
								let space = rootFolder.find(url)
								?? SpaceFile(url: url)
								folder.drop(space)
								DispatchQueue.main.async {
									folder._children = nil
									space._children = nil
								}
							}
						}
						return true
					}
				})
			.onChange(of: selection) { [selection] next in
				if next == nil && selection != nil {
					self.selection = selection
				}
			}
		}
	}
}

