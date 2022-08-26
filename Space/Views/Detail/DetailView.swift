//
//  ViewerView.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI
import UniformTypeIdentifiers

struct DetailView: View {
	var file: SpaceFile
	@EnvironmentObject var appState: SpaceState
	
	var body: some View {
		HSplitView {
			if file.conforms(to: TextEditorDetailView.supportedTypes) {
				TextEditorDetailView(file: file)
			} else if file.conforms(to: SpaceFile.videoTypes) {
				MediaPlayerDetailView(file: file)
			} else {
				QuickLookDetailView(url:file.url)
					.background()
			}
			if appState.annotationExists(for: file) {
				TextEditorDetailView(file: appState.annotationFile(for: file))
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
