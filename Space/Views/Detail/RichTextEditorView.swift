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
	@Binding var file: SpaceFile
	@State var ready = false
	@State var richTextContent = NSAttributedString(string: "this should never be")
	@StateObject var context = RichTextContext()
	
	static let supportedTypes: [UTType] = SpaceFile.richTypes + SpaceFile.htmlTypes
	
	func save() {
		file.save(richTextContent)
	}
	
	func updateText() {
		do {
			// TODO handle failure
			let contents = file.getContents()!
			if (SpaceFile.richTypes.contains(file.type)) {
				richTextContent = try NSAttributedString(rtfData: contents)
			} else if (SpaceFile.htmlTypes.contains(file.type)) {
				// TODO fancier html
				richTextContent = NSAttributedString(html: contents, documentAttributes: .none)!
			}
			ready = true
		} catch {
		}
	}
	
	var body: some View {
		// there must be a better way.
		// (the richtext doesn't refresh properly, i'm using text because it has
		// a normal background colour)
		ZStack {
			Text("")
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.onChange(of: file) {_ in
					ready = false
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
						updateText()
					}
				}
				.onAppear {
					ready = false
					updateText()
				}
			
			if ready {
				RichTextEditor(text: $richTextContent, context: context) {editor in
					// You can customize the native text view here
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
	}
}

//struct RichTextEditorView_Previews: PreviewProvider {
//	static var previews: some View {
//		RichTextEditorView(file: nil)
//	}
//}
