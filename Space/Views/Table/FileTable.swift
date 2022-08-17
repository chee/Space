//
//  FileTable.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI

struct FileTable: View {
	@State private var selection = Set<FileItem>()
	@Binding var context: FileItem?
	@Binding var choice: FileItem?
	var openDirectory: (FileItem) -> Void
	@State private var sortOrder = [KeyPathComparator(\FileItem.name)]
	@State private var children: [FileItem]?
	var body: some View {
		if children != nil {
			Table(children!, selection: $selection, sortOrder: $sortOrder) {
				TableColumn("name", value: \.name)
				TableColumn("type", value: \.type.description)
			}.onChange(of: sortOrder) {newSort in
				children!.sort(using: newSort)
			}
		}
		Group {}
			.onChange(of: context) {newContext in
				selection.removeAll()
				choice = nil
				children = nil
				if newContext != nil {
					children = context!.children.sorted(using: sortOrder)
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
//
//struct FileTable_Previews: PreviewProvider {
//	@State var target: FileItem?
//	static var previews: some View {
//		FileTable(context: _previewRootFile, target: $target)
//	}
//}
