//
//  ContentView.swift
//  Space
//
//  Created by chee on 2022-08-11.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

let ws = NSWorkspace.shared
let fm = FileManager.default
let root = URL(fileURLWithPath: "/Users/chee/Documents/Notebooks/").resolvingSymlinksInPath()

struct FileItem: Hashable, Identifiable, CustomStringConvertible {
    var id: Self { self }
    var url: URL
    // no point being lazy right now, outlinegroup isn't lazy
    //    lazy var children: [FileItem] = {
    //           return []
    //    }()
    var children: [FileItem]?
    var icon: NSImage {
        if (children != nil) {
            return ws.icon(for: UTType.folder)
        }
        return ws.icon(
            for: UTType(filenameExtension: url.pathExtension)
            ?? UTType.content
        )
    }
    var description: String {
        return url.lastPathComponent
    }
}

func getTableContextFromSidebar(set: Set<FileItem>) -> [FileItem] {
    if set.count != 1 {
        return []
    }
    if set.first!.children == nil {
        return []
    }
    return set.first!.children!
}
//
//func getPreviewContextFromTable(set: Set<FileItem>) -> String {
//    if set.count != 1 {
//        return ""
//    }
//    if set.first!.content == nil {
//        return ""
//    }
//    return set.first!.content!
//}

func getChildren(url: URL) -> [FileItem] {
    do {
        let resourceKeys = Array<URLResourceKey>([
            .isDirectoryKey
        ])
        var children: [FileItem] = []
        for fileUrl in try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: resourceKeys) {
            guard let values = try?
                    fileUrl.resourceValues(forKeys: Set<URLResourceKey>([
                        .isDirectoryKey
                    ])),
                  let isDirectory = values.isDirectory
            else {continue}
            var file = FileItem(url: fileUrl)
            if isDirectory {
                file.children = getChildren(url: fileUrl)
            }
            children.append(file)
        }
        return children
    } catch {
        return []
    }
}

func getFiles() -> [FileItem] {
    return getChildren(url: root)
}

struct ContentView: View {
    @State private var sidebarSelection = Set<FileItem>()
    @State private var sidebarTarget: FileItem?
    @State private var tableSelection = Set<FileItem>()
    @State private var tableTarget: FileItem?
    @State private var previewText: String = ""
    let files = getFiles()
    
    var body: some View {
        HSplitView {
            List(selection: $sidebarSelection) {
                OutlineGroup(files, children: \.children) {item in
                    Image(nsImage: item.icon)
                    Text(item.description)
                }
            }
            .listStyle(.sidebar)
            .onChange(of: sidebarSelection) {selection in
                tableSelection.removeAll()
                sidebarTarget = nil
                if (selection.count == 1) {
                    sidebarTarget = sidebarSelection.first!
                }
            }
        VSplitView {
            Table(getTableContextFromSidebar(set: sidebarSelection), selection: $tableSelection) {
                TableColumn("name", value: \.url.lastPathComponent)
                TableColumn("path", value: \.url.path)
                }.onChange(of: tableSelection) {tableSelection in
                    tableTarget = nil
                    if (tableSelection.count == 1) {
                        tableTarget = tableSelection.first!
                    }
                }
                TextEditor(text: $previewText)
                    .onChange(of: tableTarget) {target in
                        if (target != nil) {
                            let contents = fm.contents(atPath: target!.url.path)
                            if (contents != nil) {
                                previewText = String(
                                    decoding: contents!,
                                    as: UTF8.self
                                )
                            }
                        }
                    }
            }
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
