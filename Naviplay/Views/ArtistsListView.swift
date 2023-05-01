//
//  ArtistsListView.swift
//  Naviplay
//
//  Created by Martin Hartl on 22.04.23.
//

import SwiftUI

struct ArtistsListView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        List(selection: $appState.selectedArtist) {
            ForEach(appState.artistsListItems) { artistListItem in
                Section(artistListItem.name) {
                    ForEach(artistListItem.artist) { artist in
                        NavigationLink(value: artist) {
                            Text(artist.name)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await appState.loadArtistsIfNeeded()
            }
        }
        .navigationTitle("Artists")
    }
}

struct ArtistsListView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistsListView(appState: .mock)
    }
}
