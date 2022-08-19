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
	// TODO code editor for plainTypes? embed emacs lol?
	static let plainTypes: [UTType] = [.plainText]
	
	var body: some View {
		HSplitView {
			if RichTextEditorView.supportedTypes.contains(file.type) {
				RichTextEditorView(file)
			} else {
				QuicklookDetailView(url:file.url).background()
			}
			if file.annotationExists {
				RichTextEditorView(file.annotationFile)
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
