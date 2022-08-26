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

struct SpaceSidebar: View {
	@EnvironmentObject var appState: SpaceState
	@Binding var folder: SpaceFile
	@Binding var selection: URL?
	var parent: [SpaceSidebar]
	
	func isExpanded(_ url: URL) -> Binding<Bool> {
		return .init(
			get: { appState.isExpandedInSidebar[url, default: false] },
			set: { appState.isExpandedInSidebar[url] = $0 }
		)
	}
	
	var body: some View {
		if folder.isFolder {
			DisclosureGroup(
				isExpanded: isExpanded(folder.url),
				content: {
					if appState.isExpandedInSidebar[folder.url] ?? false {
						ForEach(folder.getChildren(), id: \.url) {childFolder in
							SpaceSidebar(
								folder: Binding.constant(childFolder),
								selection: $selection,
								parent: [self]
							)
						}
					}
				},
				label: {
					NavigationLink(
						destination: SpaceTable(folder: $folder)
							.environmentObject(appState),
						tag: folder.url,
						selection: $selection,
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
						Button("Show in Finder", action: {appState.showInFinder(folder)})
							.keyboardShortcut("o", modifiers: [.shift, .command])
					}
					.onDrop(of: ["public.file-url"], isTargeted: nil) { (drops) -> Bool in
						for drop in drops {
							drop.loadItem(forTypeIdentifier: "public.file-url") { (data, error) in
								let droppedURL = NSURL(
									absoluteURLWithDataRepresentation: data as! Data,
									relativeTo: nil
								) as URL
								appState.drop(to: folder.url, from: droppedURL)
							}
						}
						return true
					}
				})
			.onChange(of: selection) { [selection] next in
				appState.tableSelection.removeAll()
				if next == nil && selection != nil {
					self.selection = selection
				}
			}

		}
	}
}

