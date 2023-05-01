//
//  Sidebar.swift
//  Naviplay
//
//  Created by Martin Hartl on 22.04.23.
//

import SwiftUI

struct Sidebar: View {
    @ObservedObject var appState: AppState

    var body: some View {
        List(
            selection: $appState.sidebarSelection
        ) {
            NavigationLink(value: SidebarSelection.artists) {
                Label(SidebarSelection.artists.title, systemImage: "person.fill")
            }
            Section("Albums") {
                ForEach(SidebarSelection.albumSelection) { selection in
                    NavigationLink(value: selection) {
                        Label(selection.title, systemImage: "person.fill")
                    }
                }
            }
        }
        .searchable(text: $appState.searchTerm)
        .onSubmit(of: .search) {
            Task {
                await appState.search()
            }
        }
        .navigationTitle("Naviplay")
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(appState: .mock)
    }
}
