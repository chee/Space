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
	@Binding var file: FileItem?
	@State private var annotation: FileItem?
	static let richTypes = RichTextEditorView.supportedTypes
	// TODO code editor for plainTypes? embed emacs lol?
	static let plainTypes: [UTType] = [.plainText]
	var body: some View {
		HSplitView {
			Group {
				RichTextEditorView(file: $file)
				if file != nil && !Self.richTypes.contains(file!.type) {
					QuicklookDetailView(url:file!.url).background()
				}
			}
			RichTextEditorView(file: $annotation)
		}.onChange(of: file) {newFile in
			annotation = nil
			
			if newFile == nil {
				return
			}
			
			let annotationURL = newFile!.url.appendingPathExtension("annotation")
			
			if !fm.fileExists(atPath: annotationURL.path) {
				return
			}
			
			annotation = FileItem(url: annotationURL, type: UTType.rtf)
		}
	}
}

//struct ViewerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ViewerView()
//    }
//}
