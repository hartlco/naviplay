//
//  AudioPlayer.swift
//  Naviplay
//
//  Created by Martin Hartl on 23.04.23.
//

import Foundation
import AVFoundation
import MediaPlayer

// TODO: Add AVAudioSession support
final class AudioPlayer {
    enum PlaybackState {
        case none
        case paused
        case playing(PlaybackItem)
        case finished
    }
    struct PlaybackItem {
        let duration: Duration
        let currentTime: Duration
    }

    var audioPlayer: AVPlayer!

    private let remoteCommandCenter = MPRemoteCommandCenter.shared()
    private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()

    func playAudio(url: URL, resumeIfAlreadyPlaying: Bool) {
        if let audioPlayer, resumeIfAlreadyPlaying, audioPlayer.currentURL == url {
            audioPlayer.play()
            return
        }

        let audioPlayerItem = AVPlayerItem(url: url)
        audioPlayerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        audioPlayerItem.preferredForwardBufferDuration = 10.0

        self.audioPlayer = AVPlayer(playerItem: audioPlayerItem)
        self.audioPlayer.play()

        if let duration = audioPlayer.currentItem?.duration {
            let seconds = CMTimeGetSeconds(duration)
        }

        addPeriodicTimeObserver()
        addFinishedPlaybackObserver()

        remoteCommandCenter.pauseCommand.addTarget { [weak self] event in
            self?.pause()
            return .success
        }

        remoteCommandCenter.playCommand.addTarget { [weak self] event in
            self?.resume()
            return .success
        }
    }

    func pause() {
        updateNowPlayingScreen(playbackState: .paused)
        audioPlayer.pause()
    }

    func resume() {
        audioPlayer.play()
    }

    func forward(timeInterval: TimeInterval) {
        let currentTime = audioPlayer.currentTime()
        let newTime = CMTime(seconds: currentTime.seconds + timeInterval, preferredTimescale: .max)
        audioPlayer.seek(to: newTime)
    }

    func backward(timeInterval: TimeInterval) {
        let currentTime = audioPlayer.currentTime()
        let newTime = CMTime(seconds: currentTime.seconds - timeInterval, preferredTimescale: .max)
        audioPlayer.seek(to: newTime)
    }

    func isStreamingURLPlaying(url: URL) -> Bool {
        audioPlayer?.currentURL == url && audioPlayer.timeControlStatus == .playing
    }

    var playbackStateChanged: ((PlaybackState) -> Void)?

    var timeObserverToken: Any?
    func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

        timeObserverToken = audioPlayer.addPeriodicTimeObserver(
            forInterval: time,
            queue: .main
        ) { [weak self] _ in
            guard let self,
                  let currentItem = self.audioPlayer.currentItem,
                  currentItem.duration.seconds.isFinite
            else {
                return
            }

            let currentTime = Int(currentItem.currentTime().seconds)
            let duration = Int(currentItem.duration.seconds)

            let item = PlaybackItem(
                duration: Duration.seconds(duration),
                currentTime: Duration.seconds(currentTime)
            )

            self.changePlaybackState(playbackState: .playing(item))
        }
    }

    var finishedPlaybackObserverToken: NSObjectProtocol?
    func addFinishedPlaybackObserver() {
        finishedPlaybackObserverToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.changePlaybackState(playbackState: .finished)
            }
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            audioPlayer.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    private func changePlaybackState(playbackState: PlaybackState) {
        updateNowPlayingScreen(playbackState: playbackState)
        playbackStateChanged?(playbackState)
    }

    // TODO: Finish remote playback
    private func updateNowPlayingScreen(playbackState: PlaybackState) {
        switch playbackState {
        case .finished:
            nowPlayingInfoCenter.playbackState = .stopped
            return
        case .none:
            return
        case .paused:
            nowPlayingInfoCenter.playbackState = .paused
        case .playing(let item):
            var nowPlayingInfo: [String: Any] = [:]
            nowPlayingInfo[MPMediaItemPropertyArtist] = "Test"
            nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
            nowPlayingInfoCenter.playbackState = .playing
        }
    }
}

extension AVPlayer {
    var currentURL: URL? {
        (currentItem?.asset as? AVURLAsset)?.url
    }
}
