//
//  FileTable.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI

struct TableFileItem {
	var isFolder: Bool
  var isExpanded: Bool
}

struct FileTable: View {
	@State private var selection = Set<FileItem>()
	@Binding var context: FileItem?
	@Binding var choice: FileItem?
	var showDirectoryInSidebar: (FileItem) -> Void
	@State private var sortOrder = [KeyPathComparator(\FileItem.name)]
	@State private var files: [FileItem]?
	@State private var newName = ""
	@FocusState private var focusedFile: FileItem?
	@State private var renaming = false

	func startRenaming(_ file: FileItem) {
		renaming = true
		newName = file.name
		focusedFile = file
	}
	
	func rename(_ file: FileItem, to: String) {
		let newURL = file.url.deletingLastPathComponent()
			.appendingPathComponent(to)
		file.rename(newURL)
		focusedFile = nil
		newName = ""
		selection.removeAll()
		choice!.url = newURL
	}
	
	func quitRenaming() {
		focusedFile = nil
		renaming = false
		if selection.isEmpty && choice != nil {
			selection.insert(choice!)
		}
	}
	
	func showInFinder(_ file: FileItem) {
		ws.selectFile(nil, inFileViewerRootedAtPath: file.url.path)
	}
	
	var body: some View {
		if files != nil {
			Table(files!, selection: $selection, sortOrder: $sortOrder) {
				TableColumn("") {file in
					Image(nsImage: file.icon)
						.resizable()
						.frame(width: 22, height: 22)
				}
				.width(22)
				TableColumn("name", value: \.name) {file in
					if renaming && file == choice {
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
					} else {
						Text(file.name)
					}
				}
				TableColumn("type", value: \.type.description) {file in
					Text(file.type.localizedDescription ?? file.type.description)
				}
			}
			.onChange(of: focusedFile) {focused in
				if focused != choice {
					quitRenaming()
				}
			}
			.onChange(of: sortOrder) {newSort in
				files!.sort(using: newSort)
			}
			.onDoubleClick {
				if choice != nil && focusedFile == nil {
					ws.open(choice!.url)
				}
			}
			.contextMenu {
				Button("Rename", action: {
					startRenaming(choice!)
				})
				.keyboardShortcut(.defaultAction)
				Button("Show in Finder", action: {
					showInFinder(choice!)
				})
			}
		}
		Group {}
			.onChange(of: context) {newContext in
				selection.removeAll()
				choice = nil
				files = nil
				if context != nil {
					files = context!.children
						.sorted(using: sortOrder)
						.filter {
							$0.url.pathExtension != "annotation"
						}
					if selection.count == 0 {
						selection.insert(files!.first!)
					}
				}
			}
			.onChange(of: selection) {selected in
				if selected.count == 1 && choice != selected.first! {
					choice = selected.first!
				} else if selected.count != 1 {
					choice = nil
				}
			}
			.onChange(of: choice) {choice in
				if choice != nil && selection.count == 0 {
					selection.insert(choice!)
				}
			}
	}
}
//
//struct FileTable_Previews: PreviewProvider {
//	@State var target: FileItem?
//	static var previews: some View {
//		FileTable(context: _previewRootFile, target: $target)
//	}
//}
