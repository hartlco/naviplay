//
//  PlaybackControlsView.swift
//  Naviplay
//
//  Created by Martin Hartl on 01.05.23.
//

import SwiftUI

struct PlaybackControlsView: View {
    @ObservedObject var appState: AppState

    let playingSong: Song

    var body: some View {
        HStack {
            Button {
                appState.playPreviousSong()
            } label: {
                Image(systemName: "backward.fill")
            }
            Button {
                if appState.isPlayingSong(playingSong) {
                    appState.pauseSong(song: playingSong)
                } else {
                    appState.playSong(song: playingSong, resetPlayList: false)
                }
            } label: {
                if appState.isPlayingSong(playingSong) {
                    Image(systemName: "pause.fill")
                } else {
                    Image(systemName: "play.fill")
                }
            }
            Button {
                appState.playNextSong()
            } label: {
                Image(systemName: "forward.fill")
            }
        }
    }
}

struct PlaybackControlsView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackControlsView(appState: .mock, playingSong: .mock)
    }
}
