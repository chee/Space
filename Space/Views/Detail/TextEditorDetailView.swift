//
//  RichTextEditorView.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI
import UniformTypeIdentifiers
import RichTextKit

// lol?
// https://stackoverflow.com/questions/57021722/swiftui-optional-textfield
func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
	Binding(
		get: { lhs.wrappedValue ?? rhs },
		set: { lhs.wrappedValue = $0 }
	)
}

struct TextEditorDetailView: View {
	var file: SpaceFile
	var isMediaAnnotation: Bool = false
	@StateObject var context = RichTextContext()
	@EnvironmentObject var appState: SpaceState
	@State var ready = false
	
	func text(_ file: SpaceFile) -> Binding<NSAttributedString> {
		return .init(
			get: { appState.texts[file.url, default: file.getAttributedString()] },
			set: { appState.texts[file.url] = $0 }
		)
	}
	
	static let supportedTypes: [UTType] = SpaceFile.richTypes + SpaceFile.htmlTypes + SpaceFile.plainTypes
	
	func save() {
		self.file.save(text(file).wrappedValue)
	}
	
	var body: some View {
		RichTextEditor(text: text(file), context: context, format: file.rtfFormat) {editor in
			editor.textContentInset = CGSize(width: 10, height: 20)
		}
		.onDisappear {
			file.save(text(file).wrappedValue)
		}
		.background()
		.toolbar {
			ToolbarItemGroup(placement: .status) {
				if isMediaAnnotation {
					Button {
						context.pasteText(
							"space:\(file.url.deletingPathExtension().path)?time=\(appState.playingMediaTime.seconds)",
							at: text(file).wrappedValue.length,
							moveCursorToPastedContent: true
						)
					} label: {
						Label("Insert media time", systemImage: "video.circle")
					}
				}
				Button {
					context.toggle(.bold)
				} label: {
					Label("Bold", systemImage: "bold")
				}.keyboardShortcut("b")
				
				Button(action: {
					context.toggle(.italic)
				}) {
					Label("Italic", systemImage: "italic")
				}.keyboardShortcut("i")
				
				Button(action: {
					context.toggle(.underlined)
				}) {
					Label("Underline", systemImage: "underline")
				}.keyboardShortcut("u")
				
				Button(action: {context.incrementFontSize()}) {
					Label("Increase font size", systemImage: "textformat.size.larger")
				}.keyboardShortcut("=")
				
				Button(action: {context.decrementFontSize()}) {
					Label("Decrease font size", systemImage: "textformat.size.smaller")
				}.keyboardShortcut("-")
				Button(action: save) {
					Label("Save", systemImage: "square.and.arrow.down.fill")
				}.keyboardShortcut("s")
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

//struct RichTextEditorView_Previews: PreviewProvider {
//	static var previews: some View {
//		RichTextEditorView(file: nil)
//	}
//}
