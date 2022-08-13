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

//func getTableContextFromSidebar(set: Set<FileItem>) -> [FileItem] {
//    if set.count != 1 {
//        return []
//    }
//    if set.first!.children == nil {
//        return []
//    }
//    return set.first!.children!
//}
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

func getFiles() -> [FileItem] {
    do {
        let resourceKeys = Set<URLResourceKey>([
            .nameKey,
            .isDirectoryKey,
            .parentDirectoryURLKey,
        ])
        let directoryEnumerator = fm.enumerator(at: root, includingPropertiesForKeys: Array(resourceKeys))!
        var dirstack: [FileItem] = [FileItem(url: root)]
        var lastUrl = root
        for case let currentFileUrl as URL in directoryEnumerator {
            guard let resourceValues = try? currentFileUrl.resourceValues(forKeys: resourceKeys),
                let isDirectory = resourceValues.isDirectory,
                let name = resourceValues.name,
                let fileParent = resourceValues.parentDirectory
                else {
                    continue
                }

            if (dirstack.last!.children == nil) {
                dirstack[dirstack.count - 1].children = []
            }
            
            let diff = lastUrl.pathComponents.count  - currentFileUrl.pathComponents.count
            
            if (diff > 0) {
                let last: FileItem = dirstack.popLast()!
                dirstack[dirstack.count - 1].children!.append(last)
                if (diff > 1)
            }

            if (currentFileUrl.pathComponents.count == 0) {
                
                dirstack[dirstack.count - 1].children!.append(last)
            }
            if (isDirectory) {
                let dir = FileItem(url: currentFileUrl)
                dirstack.append(dir)
            } else {
                dirstack[dirstack.count - 1]
                    .children!.append(FileItem(url: currentFileUrl))
            }
            lastUrl = currentFileUrl
        }
        let last: FileItem = dirstack.popLast()!
        dirstack[dirstack.count - 1].children!.append(last)
        return dirstack.last!.children!
    } catch {
        return [
            FileItem(
                url: URL(fileURLWithPath: "/problem")
            )]
    }
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
            List(selection: $sidebarSelection) {                OutlineGroup(files, children: \.children) {item in
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
            Table(files, selection: $tableSelection) {
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
