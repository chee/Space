//
//  RichTextEditorView.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI
import RichTextKit
import UniformTypeIdentifiers

// lol?
// https://stackoverflow.com/questions/57021722/swiftui-optional-textfield
func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
	Binding(
		get: { lhs.wrappedValue ?? rhs },
		set: { lhs.wrappedValue = $0 }
	)
}

struct RichTextEditorView: View {
	@ObservedObject var file: SpaceFile
	@State var ready = false
	@StateObject var context = RichTextContext()
	
	static let supportedTypes: [UTType] = SpaceFile.richTypes + SpaceFile.htmlTypes
	
	init(_ file: SpaceFile) {
		self.file = file
	}
	
	func save() {
		debugPrint(file.url, file.type)
		self.file.save()
	}
	
	var body: some View {
		ZStack {
			// RichTextEditor really doesn't notice if i change the text. do i need to fork this?
			if ready {
				RichTextEditor(text: $file.richText, context: context) {editor in
					// You can customize the native text view here
					editor.textContentInset = CGSize(width: 10, height: 20)
				}.onChange(of: file) {_ in
					ready = false
					file.loadRichText()
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
						ready = true
					}
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
		}.onAppear {
			file.loadRichText()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				ready = true
			}
		}.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

//struct RichTextEditorView_Previews: PreviewProvider {
//	static var previews: some View {
//		RichTextEditorView(file: nil)
//	}
//}
