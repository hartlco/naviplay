//
//  State.swift
//  Naviplay
//
//  Created by Martin Hartl on 22.04.23.
//

import SwiftUI
import AVFoundation
import KeychainAccess

enum SidebarSelection: Identifiable, Hashable, Equatable, Codable {
    case artists
    case recentlyAdded
    case random

    static var albumSelection: [SidebarSelection] {
        [
            .recentlyAdded,
            .random
        ]
    }

    var title: String {
        switch self {
        case .artists: return "Artists"
        case .recentlyAdded: return "Recently Added"
        case .random: return "Random"
        }
    }

    var id: String {
        return title
    }
}

enum SearchSelection: Hashable {
    case artist(ListArtist)
    case album(ListAlbum)
}

struct Playlist {
    var playingSong: Song
    var songs: [Song]
}

public final class AppState: ObservableObject {
    @Published var sidebarSelection: SidebarSelection? = .artists {
        didSet {
            switch sidebarSelection {
            case .none:
                return
            case .recentlyAdded:
                Task {
                    await loadRecentlyAdded()
                }
            case .random:
                Task {
                    await loadRandom()
                }
            case .artists:
                return
            }
        }
    }

    @Published var authenticationState: AuthenticationState

    @Published var artistsListItems: [ArtistListItem] = []

    @Published var selectedArtist: ListArtist? {
        didSet {
            Task {
                await loadSelectedArtistAlbums()
            }
        }
    }

    @Published var selectedArtistAlbums: [ListAlbum] = []

    @Published var selectedAlbum: [ListAlbum] = [] {
        didSet {
            Task {
                await loadSelectedAlbumSongs()
            }
        }
    }

    @Published var displayedSongs: [Song] = []

    @Published var selectedSong: Song?

    @Published var playlist: Playlist?

    @Published var playbackItem: AudioPlayer.PlaybackItem?

    @Published var searchTerm: String = ""

    @Published var searchResult: SearchResult?

    @Published var selectedSearchResult: SearchSelection? {
        didSet {
            switch selectedSearchResult {
            case .album(let album):
                selectedAlbum = [album]
            case .artist(let artist):
                selectedArtist = nil
                selectedArtist = artist
            case .none:
                return
            }
        }
    }

    @Published var selectedAlbumList: [ListAlbum] = []

    @Published var selectedAlbumListAlbum: ListAlbum? {
        didSet {
            Task {
                await loadSelectedAlbumListAlbumSongs()
            }
        }
    }

    init(keychain: Keychain) {
        let authenticationState = AuthenticationState(keychain: keychain)
        self.authenticationState = .init(keychain: keychain)
        self.client = NavidromeClient(
            authenticationProvider:
                    .init(usernamePasswordProvider: authenticationState)
        )

        audioPlayer.playbackStateChanged = { [weak self] state in
            switch state {
            case .none:
                return
            case .playing(let item):
                self?.playbackItem = item
            case .finished:
                self?.finishedPlayback()
            case .paused:
                return
            }
        }
    }

    private let client: NavidromeClient
    private let audioPlayer = AudioPlayer()

    @MainActor
    func loadArtistsIfNeeded() async {
        guard artistsListItems.isEmpty else {
            return
        }

        do {
            artistsListItems = try await client.getArtists()
        } catch {
            // TODO: Error handling
        }
    }

    @MainActor
    func loadSelectedArtistAlbums() async {
        guard let selectedArtist else {
            return
        }

        do {
            selectedArtistAlbums = try await client.getArtistAlbums(artist: selectedArtist)
        } catch {
            print(error)
            // TODO: Error handling
        }
    }

    @MainActor
    func loadSelectedAlbumSongs() async {
        if let lastAlbum = selectedAlbum.last {
            do {
                displayedSongs = try await client.getAlbumSongs(album: lastAlbum)
            } catch {
                print(error)
            }
        }
    }

    @MainActor
    func loadSelectedAlbumListAlbumSongs() async {
        if let selectedAlbumListAlbum {
            do {
                displayedSongs = try await client.getAlbumSongs(album: selectedAlbumListAlbum)
            } catch {
                print(error)
            }
        }
    }

    @MainActor
    func search() async {
        do {
            searchResult = try await client.search(term: searchTerm)
        } catch {
            print(error)
        }
    }

    @MainActor
    func loadRecentlyAdded() async {
        do {
            selectedAlbumList = try await client.getAlbumList(type: .newest)
        } catch {
            // TODO: Error handling
            print(error)
        }
    }

    @MainActor
    func loadRandom() async {
        do {
            selectedAlbumList = try await client.getAlbumList(type: .random)
        } catch {
            // TODO: Error handling
            print(error)
        }
    }

    func isPlayingSong(_ song: Song) -> Bool {
        do {
            if song != playlist?.playingSong {
                return false
            } else {
                if try audioPlayer.isStreamingURLPlaying(
                    url: client.streamURL(id: song.id)
                ) {
                    return true
                }

                return false
            }
        } catch {
            return false
        }
    }

    func playSong(song: Song, resetPlayList: Bool) {
        do {
            try audioPlayer.playAudio(
                url: client.streamURL(id: song.id),
                resumeIfAlreadyPlaying: true
            )
            if resetPlayList {
                playlist = .init(
                    playingSong: song,
                    songs: displayedSongs
                )
            } else if let playlist {
                self.playlist = .init(
                    playingSong: song,
                    songs: playlist.songs
                )
            } else {
                fatalError("Should not happen")
            }
        } catch {
            // TODO: Error handling
            print(error)
        }
    }

    // TODO: Extract AudioPlayback State
    func pauseSong(song: Song) {
        audioPlayer.pause()
    }

    func forward(timeInterval: TimeInterval) {
        audioPlayer.forward(timeInterval: timeInterval)
    }

    func backward(timeInterval: TimeInterval) {
        audioPlayer.backward(timeInterval: timeInterval)
    }

    func coverImageURL(song: Song) -> URL? {
        client.coverImageURL(song: song)
    }

    // TODO: Bug when last song ins played - next playing song not correctly updated
    func playNextSong() {
        if let playlist,
            !playlist.songs.isEmpty,
            let currentIndex = playlist.songs.firstIndex(of: playlist.playingSong),
           let lastSong = playlist.songs.last,
           playlist.playingSong != lastSong
        {
            let nextSong = playlist.songs[currentIndex + 1]
            playSong(song: nextSong, resetPlayList: false)
        } else {
            playlist = nil
        }
    }

    // TODO: Bug when first song ins played - next playing song not correctly updated
    func playPreviousSong() {
        if let playlist,
            !playlist.songs.isEmpty,
            let currentIndex = playlist.songs.firstIndex(of: playlist.playingSong),
           currentIndex > 0
        {
            let nextSong = playlist.songs[currentIndex - 1]
            playSong(song: nextSong, resetPlayList: false)
        } else {
            playlist = nil
        }
    }

    private func finishedPlayback() {
        playbackItem = nil
        playNextSong()
    }

    static var mock: AppState {
        AppState(keychain: .init())
    }
}
