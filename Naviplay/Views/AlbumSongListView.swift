//
//  AlbumSongListView.swift
//  Naviplay
//
//  Created by Martin Hartl on 22.04.23.
//

import SwiftUI

struct AlbumSongListView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        List(selection: $appState.selectedSong) {
            ForEach(appState.displayedSongs) { song in
                SongListItemView(appState: appState, song: song)
                .tag(song)
            }
        }
    }
}

struct AlbumSongListView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumSongListView(appState: .mock)
    }
}
