//
//  ContentView.swift
//  Space
//
//  Created by chee on 2022-08-11.
//

import SwiftUI
import AppKit

struct ContentView: View {
	let rootURL = URL(
		fileURLWithPath: "/Users/chee/Documents/Notebooks/"
	).resolvingSymlinksInPath()

	var body: some View {
		MainView(rootURL)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ContentView()
				.preferredColorScheme(.dark)
			ContentView()
				.preferredColorScheme(.light)
		}
	}
}
