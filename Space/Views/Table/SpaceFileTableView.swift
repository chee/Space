//
//  SpaceFileTableView.swift
//  Space
//
//  Created by chee on 2022-08-17.
//

import SwiftUI


struct SpaceFileTableView<Content>: NSViewRepresentable where Content: View {
	let items: [FileItem]
	let content: Content
	
	func makeCoordinator() -> Coordinator {
		Coordinator(items, content: content)
	}
	
	class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
		var items: [FileItem]
		var content: Content
		
		init(_ items: [FileItem], content: Content) where Content: View {
			self.items = items
			self.content = content
		}
		
		func numberOfRows(in tableView: NSTableView) -> Int {
			items.count
		}
		
		func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
			22
		}
		
		func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
			let cell = NSTableCellView()
			cell.addSubview(NSHostingView(rootView: AnyView(content)))
			return cell
		}
	}
	
	func makeNSView(context: Context) -> NSScrollView {
		let tableView = NSTableView()
		
		let column = NSTableColumn(identifier: .init(rawValue: "first"))
		tableView.addTableColumn(column)
		tableView.headerView = nil
		
		let coordinator = context.coordinator
		tableView.delegate = coordinator
		tableView.dataSource = coordinator
		tableView.target = coordinator
		tableView.style = .sourceList
		tableView.usesAutomaticRowHeights = true
		
		let scrollView = NSScrollView()
		scrollView.hasVerticalScroller = true
		scrollView.hasHorizontalRuler = true
		scrollView.autohidesScrollers = true
		scrollView.documentView = tableView
		
		tableView.reloadData()
		
		return scrollView
	}
	
	func updateNSView(_ nsView: NSScrollView, context: Context) {
	}
}

//struct SpaceFileTableView_Previews: PreviewProvider {
//	static var previews: some View {
//		SpaceFileTableView(items: _previewRootFile.children)
//	}
//}
