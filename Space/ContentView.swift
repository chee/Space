//
//  ContentView.swift
//  Space
//
//  Created by chee on 2022-08-11.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import Quartz

struct QLImage: NSViewRepresentable {
    var url: URL
    
    func makeNSView(context: NSViewRepresentableContext<QLImage>) -> QLPreviewView {
        let preview = QLPreviewView(frame: .zero, style: .normal)
        preview?.autostarts = true
        preview?.previewItem = url as QLPreviewItem
        
        return preview ?? QLPreviewView()
    }
    
    func updateNSView(_ nsView: QLPreviewView, context: NSViewRepresentableContext<QLImage>) {
        nsView.previewItem = url as QLPreviewItem
    }
    
    typealias NSViewType = QLPreviewView
}


let ws = NSWorkspace.shared
let fm = FileManager.default
let root = URL(
    fileURLWithPath: "/Users/chee/Documents/Notebooks/"
).resolvingSymlinksInPath()


struct SidebarFileView: View {
    var file: FileItem
    @State var isExpanded: Bool = false

    var body: some View {
        if file.isFolder {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    if isExpanded {
                        ForEach(getChildren(url: file.url), id: \.self.id) { childNode in
                            SidebarFileView(file: childNode)
                        }
                    }
                },
                label: {
                    Image(nsImage: file.icon)
                    Text(" " + file.name)
                })
        }
    }

}

struct FileItem: Identifiable, Hashable, Equatable, Comparable {
    static func < (lhs: FileItem, rhs: FileItem) -> Bool {
        return lhs.name < rhs.name
    }
    
    var id: Self {self}
    var url: URL
    
    lazy var children = {
       return getChildren(url: url).sorted()
    }()

    var isFolder: Bool { self.type == UTType.folder }
    var icon: NSImage
    var type: UTType
    var name: String
    
    init(url: URL, type: UTType?) {
        self.url = url
        self.icon = ws.icon(for: type ?? UTType.content)
        self.name = url.lastPathComponent
        self.type = type ?? UTType.content
        
    }
}

func getChildren(url: URL) -> [FileItem] {
    do {
        let resourceKeys = Array<URLResourceKey>([
            .contentTypeKey,
        ])
        var children: [FileItem] = []
        for fileUrl in try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: resourceKeys) {
            guard let values = try?
                    fileUrl.resourceValues(forKeys: Set<URLResourceKey>([
                        .contentTypeKey
                    ])),
                  let contentType = values.contentType
            else {continue}
            children.append(FileItem(
                url: fileUrl,
                type: contentType
            ))
        }
        return children
    } catch {
        return []
    }
}


struct ContentView: View {
    @State var sidebarSelection = Set<FileItem>()
    @State var expansion: Set<UUID> = []
    @State var sidebarTarget: [FileItem]?
    @State private var tableSelection = Set<FileItem>()
    @State private var tableTarget: FileItem?
    @State private var previewText: String = ""
    let dirs = [FileItem(
        url: root,
        type: UTType.folder // custom icons?
    )].sorted()

    var body: some View {
        HSplitView {
            List(dirs, selection: $sidebarSelection) {file in
                SidebarFileView(file: file, isExpanded: true)
            }
            .onChange(of: sidebarSelection) {selection in
                tableSelection.removeAll()
                sidebarTarget = nil
                if (selection.count == 1) {
                    var target = selection.first!
                    sidebarTarget = target.children
                }
            }
            .frame(idealWidth: 10, alignment: .leading)
            VSplitView {
                if sidebarTarget != nil {
                    Table(sidebarTarget!, selection: $tableSelection) {
                        TableColumn("name", value: \.url.lastPathComponent)
                        TableColumn("path", value: \.url.path)
                    }.onChange(of: tableSelection) {tableSelection in
                        tableTarget = nil
                        if (tableSelection.count == 1) {
                            tableTarget = tableSelection.first!
                        }
                    }
                }
                if tableTarget != nil {
                    QLImage(url:tableTarget!.url)
                }
            }
            .frame(minWidth: 400, alignment: .trailing)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark)
            ContentView()
        }
    }
}
