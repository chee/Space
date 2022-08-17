//
//  SidebarView.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI

struct SidebarView: View {
	@State private var selection = Set<FileItem>()
	@State private var expansion: Set<UUID> = []
	var dirs: [FileItem]
	@Binding var choice: FileItem?
	
	var body: some View {
		List(dirs, selection: $selection) {file in
			SidebarFileTree(file: file, isExpanded: true)
		}
		.onChange(of: selection) {selection in
			choice = nil
			if (selection.count == 1) {
				choice = selection.first!
			}
		}
		.frame(idealWidth: 10, alignment: .leading)
	}
}
//
//struct SidebarView_Previews: PreviewProvider {
//	@State var target: FileItem?
//	static var previews: some View {
//		SidebarView(dirs: [_previewRootFile], target: $target)
//	}
//}
