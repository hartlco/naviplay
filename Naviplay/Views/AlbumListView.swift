//
//  AlbumListView.swift
//  Naviplay
//
//  Created by Martin Hartl on 25.04.23.
//

import SwiftUI

struct AlbumListView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        List(selection: $appState.selectedAlbumListAlbum) {
            ForEach(appState.selectedAlbumList) { album in
                NavigationLink(album.name, value: album)
            }
        }
    }
}

struct AlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumListView(appState: .mock)
    }
}
