//
//  ViewerView.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI
import UniformTypeIdentifiers

struct DetailView: View {
	let file: SpaceFile
	// TODO code editor for plainTypes? embed emacs lol?
	static let plainTypes: [UTType] = [.plainText]
	
	var body: some View {
		HSplitView {
			if TextEditorDetailView.supportedTypes.contains(file.type) {
				TextEditorDetailView(file)
					.background()
			} else {
				QuickLookDetailView(url:file.url)
					.background()
			}
			if file.annotationExists {
				TextEditorDetailView(file.annotationFile)
					.background()
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
