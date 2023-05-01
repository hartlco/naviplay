//
//  SearchResultListView.swift
//  Naviplay
//
//  Created by Martin Hartl on 23.04.23.
//

import SwiftUI

struct SearchResultListView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        if let result = appState.searchResult {
            List(selection: $appState.selectedSearchResult) {
                if let artists = result.artist {
                    Section("Artists") {
                        ForEach(artists) { artist in
                            NavigationLink(value: SearchSelection.artist(artist)) {
                                Text(artist.name)
                            }
                        }
                    }
                }
                if let albums = result.album {
                    Section("Album") {
                        ForEach(albums) { album in
                            NavigationLink(value: SearchSelection.album(album)) {
                                Text(album.name)
                            }
                        }
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

struct SearchResultListView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultListView(appState: .mock)
    }
}
