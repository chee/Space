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

extension NSAttributedString {
	public var asHtml: String? {
		let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
		do {
			let htmlData = try data(from: NSMakeRange(0, length), documentAttributes: documentAttributes)
			if let htmlString = String(data: htmlData, encoding: String.Encoding.utf8) {
				return htmlString
			}
		} catch {
			
		}
		return nil
	}
}

struct RichTextEditorView: View {
	@Binding var file: SpaceFile
	@State var ready = false
	@State var richTextContent = NSAttributedString(string: "this should never be")
	@StateObject var context = RichTextContext()
	
	static let richTypes: [UTType] = [.rtf, .rtfd, .flatRTFD]
	static let htmlTypes: [UTType] = [.html]
	static let supportedTypes: [UTType] = richTypes + htmlTypes
	
	func save() {
		//		if let file = file, let text = text {
		//			if Self.richTypes.contains(file.type) {
		//				do {
		//					let rtf = try text.richTextRtfData()
		//					try rtf.write(to: file.url)
		//				} catch {
		//					print("failed to write file :o")
		//				}
		//			} else if Self.htmlTypes.contains(file.type) {
		//				let html = text.asHtml!
		//				do {
		//					try html.data(using: .utf8)?.write(to: file.url)
		//				} catch {
		//					print("failed to write file")
		//				}
		//			}
		//		}
	}
	
	func updateText() {
		do {
			// TODO handle failure
			let contents = file.getContents()!
			if (Self.richTypes.contains(file.type)) {
				richTextContent = try NSAttributedString(rtfData: contents)
			} else if (Self.htmlTypes.contains(file.type)) {
				// TODO fancier html
				richTextContent = NSAttributedString(html: contents, documentAttributes: .none)!
			}
			ready = true
		} catch {
		}
	}
	
	var body: some View {
		HStack {
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
		.onChange(of: file) {_ in
			ready = false
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
				updateText()
			}
		}
		.onAppear {
			print("i have made my appearence")
			ready = false
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
				updateText()
			}
		}
	}
}

//struct RichTextEditorView_Previews: PreviewProvider {
//	static var previews: some View {
//		RichTextEditorView(file: nil)
//	}
//}
