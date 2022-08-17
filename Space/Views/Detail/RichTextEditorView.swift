//
//  RichTextEditorView.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import SwiftUI
import RichTextKit
import UniformTypeIdentifiers

struct RichTextEditorView: View {
	@Binding var file: FileItem?
	@State var text: NSAttributedString?
	@StateObject var context = RichTextContext()

	static let richTypes: [UTType] = [.rtf, .rtfd, .flatRTFD]
	static let htmlTypes: [UTType] = [.html]
	static let supportedTypes: [UTType] = richTypes + htmlTypes
	
	var body: some View {
		Group {
			if let text = text {
				RichTextEditor(text: Binding<NSAttributedString>.constant(text), context: context) {editor in
					// You can customize the native text view here
					editor.textContentInset = CGSize(width: 10, height: 20)
				}.background()
			}
		}.onChange(of: file) {new in
			print("rich text editor sees a new file :)")
			text = nil
			if file == nil {
				return
			}
			do {
				print("doing it with the text")
				let type = new!.type
				if (Self.richTypes.contains(type)) {
					try text = NSAttributedString(rtfData: file!.contents)
				} else if (Self.htmlTypes.contains(type)) {
					text = NSAttributedString(html: file!.contents, documentAttributes: .none)!
				} else {
					return
				}
				print("did it with the text")
			} catch {
				print("no rtf babe")
			}
		}
	}
}


//struct RichTextEditorView_Previews: PreviewProvider {
//	static var previews: some View {
//		RichTextEditorView(file: nil)
//	}
//}
