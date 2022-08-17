//
//  QLImage.swift
//  Space
//
//  Created by chee on 2022-08-16.
//

import Foundation
import SwiftUI
import AppKit
import Quartz

struct QLImage: NSViewRepresentable {
	var url: URL
	
	func makeNSView(context: NSViewRepresentableContext<QLImage>) -> QLPreviewView {
		let preview = QLPreviewView(frame: .zero, style: .normal)
		preview?.autostarts = false
		preview?.previewItem = url as QLPreviewItem
		
		return preview ?? QLPreviewView()
	}
	
	func updateNSView(_ nsView: QLPreviewView, context: NSViewRepresentableContext<QLImage>) {
		nsView.previewItem = url as QLPreviewItem
	}
	
	typealias NSViewType = QLPreviewView
}
