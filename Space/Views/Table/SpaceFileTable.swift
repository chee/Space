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
	@State private var renaming = false
	@State private var newName = ""
	@FocusState private var focusedFile: FileItem?
	
	func startRenaming(_ file: FileItem) {
		newName = file.name
		focusedFile = file
		renaming = true
	}
	
	func rename(_ file: FileItem, to: String) {
		let newURL = file.url.deletingLastPathComponent()
			.appendingPathComponent(to)
		file.rename(newURL)
		renaming = false
		newName = ""
		selection.removeAll()
	}
	
	func quitRenaming(_ file: FileItem) {
		renaming = false
		if selection.isEmpty {
			selection.insert(file)
		}
	}
	
	func showInFinder(_ file: FileItem) {
		ws.selectFile(nil, inFileViewerRootedAtPath: file.url.path)
	}
	
	var body: some View {
		if let items = files {
			List(items, selection: $selection) {file in
				if renaming && selection.count == 1 && selection.first! == file {
					
					HStack {
						Image(nsImage: file.icon)
							.resizable()
							.frame(width: 22, height: 22, alignment: .leading)
						TextField(file.name, text: $newName)
							.focused($focusedFile, equals: file)
							.frame(alignment: .leading)
							.onSubmit {
								self.rename(file, to: newName)
								context?.loadChildren()
								files = context?.children
									.sorted(using: sortOrder)
									.filter {
										$0.url.pathExtension != "annotation"
									}
								let updated = files?.first(where: {$0.url.lastPathComponent == newName})
								if let updated = updated {
									selection.insert(updated)
								}
							}
							.onChange(of: focusedFile) {focused in
								if focused != file {
									quitRenaming(file)
								}
							}
						Text(file.type.identifier)
						Spacer()
					}
				} else {
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
					.contextMenu {
						Button("Rename", action: {
							startRenaming(file)
						})
						.keyboardShortcut(.defaultAction)
						Button("Show in Finder", action: {
							showInFinder(file)
						})
					}
				}
			}.listStyle(.bordered(alternatesRowBackgrounds: true))
		}
		Group{}
			.onChange(of: context) {newContext in
				print("context changed")
				selection.removeAll()
				choice = nil
				files = nil
				if context != nil {
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

