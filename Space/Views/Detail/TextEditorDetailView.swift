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
	@ObservedObject var file: SpaceFile
	@StateObject var context = RichTextContext()
	@State var ready = false
	
	static let supportedTypes: [UTType] = SpaceFile.richTypes + SpaceFile.htmlTypes
	
	init(_ file: SpaceFile) {
		self.file = file
	}
	
	func save() {
		self.file.save()
	}
	
	var body: some View {
		ZStack {
			if Binding($file.richText) != nil {
				RichTextEditor(text: Binding($file.richText)!, context: context) {editor in
					editor.textContentInset = CGSize(width: 10, height: 20)
				}
				.background()
				.toolbar {
					ToolbarItemGroup(placement: .status) {
						Button(action: {
							context.toggle(.bold)
						}) {
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
