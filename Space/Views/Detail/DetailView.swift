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
	
	var isMedia: Bool {
		file.conforms(to: SpaceFile.mediaTypes)
	}
	
	var body: some View {
		HSplitView {
			if isMedia {
				MediaPlayerDetailView(file: file)
					.environmentObject(appState)
			} else if file.conforms(to: TextEditorDetailView.supportedTypes) {
				TextEditorDetailView(file: file)
			} else {
				QuickLookDetailView(url:file.url)
					.background()
			}
			if appState.annotationExists(for: file) {
				TextEditorDetailView(
					file: appState.annotationFile(for: file),
					isMediaAnnotation: isMedia
				).background()
			}
		}
	}
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//			DetailView(file: SpaceFile(url: URL(fileURLWithPath: "~/x")))
//    }
//}
