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

	var body: some View {
		if context != nil {
			Table(context!.children, selection: $selection) {
				TableColumn("name", value: \.name)
				TableColumn("type", value: \.type.description)
			}.onChange(of: context) {newContext in
				selection.removeAll()
				choice = nil
			}.onChange(of: selection) {selected in
				choice = nil
				if (selected.count == 1) {
					choice = selected.first!
				}
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
