//
//  MediaPlayerDetailView.swift
//  Space
//
//  Created by chee on 2022-08-25.
//

import SwiftUI
import AVKit

class MediaPlayer : AVPlayer, ObservableObject {}

struct MediaPlayerDetailView: View {
	var file: SpaceFile
	@StateObject var player: MediaPlayer
	@State private var currentTime: CMTime?
	@State var injectedTime: CMTime?
	init(file: SpaceFile) {
		self.file = file
		self._player = StateObject(
			wrappedValue: MediaPlayer(url: file.url)
		)
	}
	var body: some View {
		VideoPlayer(player: player)
			.onChange(of: player.currentTime()) {time in
				self.currentTime = time
			}
			.onChange(of: injectedTime) {_ in
				if let time = injectedTime {
					player.seek(to: time)
				}
			}
	}
}

struct MediaPlayerDetailView_Previews: PreviewProvider {
	static var previews: some View {
		MediaPlayerDetailView(file: _previewRootFile)
	}
}
