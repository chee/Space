//
//  ViewerView.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI
import UniformTypeIdentifiers
import RichTextKit

struct DetailView: View {
	let file: SpaceFile
	static let richTypes = RichTextEditorView.supportedTypes
	// TODO code editor for plainTypes? embed emacs lol?
	static let plainTypes: [UTType] = [.plainText]
	var annotationURL: URL {
		file.url.appendingPathExtension("annotation")
	}
	
	func annotationExists () -> Bool {
		return fm.fileExists(atPath: annotationURL.path)
	}
	
	var body: some View {
		HSplitView {
			if Self.richTypes.contains(file.type) {
				RichTextEditorView(url: file.url)
			} else {
				QuicklookDetailView(url:file.url).background()
			}
			if annotationExists() {
				RichTextEditorView(url: file.url)
			}
		}
	}
}

//
//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//			DetailView(file: SpaceFile(url: URL(fileURLWithPath: "~/x")))
//    }
//}
