//
//  SongListItemView.swift
//  Naviplay
//
//  Created by Martin Hartl on 23.04.23.
//

import SwiftUI

struct SongListItemView: View {
    static let formatter = DateComponentsFormatter()

    @ObservedObject var appState: AppState
    let song: Song

    var body: some View {
        HStack(alignment: .center) {
            Button {
                if appState.isPlayingSong(song) {
                    appState.pauseSong(song: song)
                } else {
                    appState.playSong(song: song, resetPlayList: true)
                }
            } label: {
                if appState.isPlayingSong(song) {
                    Image(systemName: "pause")
                } else {
                    Image(systemName: "play")
                }
            }

            Text(String(song.track))
                .font(.footnote)
            Text(song.title)
            Spacer()
            Text(Self.formatter.string(from: song.duration) ?? "")
                .font(.footnote)
        }
    }
}

struct SongListItemView_Previews: PreviewProvider {
    static var previews: some View {
        SongListItemView(appState: .mock, song: .mock)
    }
}
