//
//  ContentView.swift
//  Naviplay
//
//  Created by Martin Hartl on 22.04.23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack {
            NavigationSplitView {
                Sidebar(appState: appState)
            } content: {
                if !appState.searchTerm.isEmpty {
                    SearchResultListView(appState: appState)
                } else {
                    switch appState.sidebarSelection {
                    case .artists:
                        ArtistsListView(appState: appState)
                    case .recentlyAdded, .random:
                        AlbumListView(appState: appState)
                    case .none:
                        Text("Empty")
                    }
                }
            } detail: {
                switch appState.sidebarSelection {
                case .artists:
                    NavigationStack(path: $appState.selectedAlbum) {
                        AlbumArtistListView(appState: appState)
                        .navigationDestination(for: ListAlbum.self) { album in
                            AlbumSongListView(appState: appState)
                        }
                    }
                case .recentlyAdded, .random:
                    AlbumSongListView(appState: appState)
                case .none:
                    Text("Empty")
                }
            }
            NowPlayingView(appState: appState)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appState: .mock)
    }
}
