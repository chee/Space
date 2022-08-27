//
//  MediaPlayerDetailView.swift
//  Space
//
//  Created by chee on 2022-08-25.
//

import SwiftUI
import AVKit

class SpaceMediaPlayer : AVPlayer, ObservableObject {
	var observer: Any? = nil
	
	func addSpaceTimeObserver(seconds: Double, for binding: Binding<CMTime>) {
		let interval = CMTime(
			seconds: seconds,
			preferredTimescale: CMTimeScale(NSEC_PER_SEC)
		)
		observer = addPeriodicTimeObserver(
			forInterval: interval,			
			queue: .main) {[weak self] time in
				guard let _ = self else { return }
				binding.wrappedValue = time
			}
	}
	
	func removeSpaceTimeObserver() {
//		if let observer = observer {
//			fix this because it's probably a memory leak lol
//			removeTimeObserver(observer)
//		}
	}
}

struct MediaPlayerDetailView: View {
	var file: SpaceFile
	@EnvironmentObject var appState: SpaceState
	@StateObject var player: SpaceMediaPlayer
	init(file: SpaceFile) {
		self.file = file
		let p = SpaceMediaPlayer(url: file.url)
		self._player = StateObject(
			wrappedValue: p
		)
	}
	var body: some View {
		VideoPlayer(player: player)
			.onChange(of: appState.setMediaTime) {_ in
				if let time = self.appState.setMediaTime {
					self.player.seek(to: time)
					self.player.play()
				}
			}
			.onAppear {
				player.addSpaceTimeObserver(seconds: 0.5, for: $appState.playingMediaTime)
			}
			.onDisappear {
				player.removeSpaceTimeObserver()
			}
	}
}

struct MediaPlayerDetailView_Previews: PreviewProvider {
	static var previews: some View {
		MediaPlayerDetailView(file: _previewRootFile)
	}
}
