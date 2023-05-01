//
//  PlaybackDurationView.swift
//  Naviplay
//
//  Created by Martin Hartl on 23.04.23.
//

import SwiftUI

struct PlaybackDurationView: View {
    let playbackItem: AudioPlayer.PlaybackItem?

    var body: some View {
        if let playbackItem = playbackItem {
            HStack {
                Text(String(playbackItem.currentTime.formatted(.time(pattern: .minuteSecond))))
                ProgressView(
                    value: Float(playbackItem.currentTime.components.seconds),
                    total: Float(playbackItem.duration.components.seconds)
                )
                .frame(maxWidth: 120)
                Text(String(playbackItem.duration.formatted(.time(pattern: .minuteSecond))))
            }
        } else {
            Text("Not playing")
        }
    }
}

struct PlaybackDurationView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackDurationView(playbackItem: nil)
    }
}
