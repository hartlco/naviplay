//
//  AlbumArtistListView.swift
//  Naviplay
//
//  Created by Martin Hartl on 22.04.23.
//

import SwiftUI

struct AlbumArtistListView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        List {
            ForEach(appState.selectedArtistAlbums) { album in
                NavigationLink(album.name, value: album)
            }
        }
    }
}

struct AlbumArtistListView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumArtistListView(appState: .mock)
    }
}
