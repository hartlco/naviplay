//
//  NowPlayingView.swift
//  Naviplay
//
//  Created by Martin Hartl on 23.04.23.
//

import SwiftUI

struct NowPlayingView: View {
    static var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    @ObservedObject var appState: AppState

    private let formatter = Self.formatter

    var body: some View {
        HStack {
            if let playingSong = appState.playlist?.playingSong {
                CoverImage(
                    coverImageURL: appState.coverImageURL(song: playingSong),
                    size: .init(width: 60, height: 60)
                )
                .padding(8.0)
                Spacer()
                VStack(alignment: .center) {
                    Text("\(playingSong.artist) - \(playingSong.title)")
                    PlaybackDurationView(playbackItem: appState.playbackItem)
                }
                Spacer()
                PlaybackControlsView(
                    appState: appState,
                    playingSong: playingSong
                )
                .padding(8.0)
            } else {
                Text("Nothing playing")
            }
        }
    }
}

struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingView(appState: .mock)
    }
}
