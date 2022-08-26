//
//  ViewerView.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI
import UniformTypeIdentifiers

struct DetailView: View {
	@State var file: SpaceFile
	
	var body: some View {
		HSplitView {
			if file.conforms(to: TextEditorDetailView.supportedTypes) {
				TextEditorDetailView(file: file)
			} else {
				QuickLookDetailView(url:file.url)
					.background()
			}
			if file.annotationExists {
				TextEditorDetailView(file: file.annotationFile)
					.background()
			}
		}
	}
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//			DetailView(file: SpaceFile(url: URL(fileURLWithPath: "~/x")))
//    }
//}
