//
//  NavidromeClient.swift
//  Naviplay
//
//  Created by Martin Hartl on 22.04.23.
//

import Foundation
import CryptoKit

protocol UsernamePasswordProvider: AnyObject {
    func getUsername() -> String
    func getPassword() -> String
    func getUrlString() -> String
}

public class NavidromeClientAuthenticationProvider {
    public var authentication: Authentication {
        .init(
            user: usernamePasswordProvider.getUsername(),
            token: token,
            salt: salt,
            baseURLString: usernamePasswordProvider.getUrlString()
        )
    }

    init(
        usernamePasswordProvider: UsernamePasswordProvider
    ) {
        self.usernamePasswordProvider = usernamePasswordProvider
    }

    private let usernamePasswordProvider: UsernamePasswordProvider
    private var salt: String = UUID().uuidString

    private var token: String {
        let passwordString = usernamePasswordProvider.getPassword() + salt
        let digest = Insecure.MD5.hash(data: Data(passwordString.utf8))

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

public final class NavidromeClient {
    private let urlSession = URLSession.shared
    private let authenticationProvider: NavidromeClientAuthenticationProvider

    init(authenticationProvider: NavidromeClientAuthenticationProvider) {
        self.authenticationProvider = authenticationProvider
    }
    
    func getArtists() async throws -> [ArtistListItem] {
        let url = try Path.artists.url(using: authenticationProvider.authentication)

        let (data, _) = try await urlSession.data(for: .init(url: url))
        let artistListResponse = try JSONDecoder().decode(ArtistListResponse.self, from: data)
        return artistListResponse.subsonicResponse.artists.index
    }

    func getArtistAlbums(artist: ListArtist) async  throws -> [ListAlbum] {
        let url = try Path.artist(id: artist.id).url(using: authenticationProvider.authentication)

        let (data, _) = try await urlSession.data(for: .init(url: url))
        let artistListResponse = try JSONDecoder().decode(ArtistResponse.self, from: data)
        return artistListResponse.subsonicResponse.artist.album
    }

    func getAlbumSongs(album: ListAlbum) async throws -> [Song] {
        let url = try Path.album(id: album.id).url(using: authenticationProvider.authentication)

        print(url)
        let (data, _) = try await urlSession.data(for: .init(url: url))
        let albumResponse = try JSONDecoder().decode(AlbumResponse.self, from: data)
        return albumResponse.subsonicResponse.album.song
    }

    func search(term: String) async throws -> SearchResult {
        let url = try Path.search(term: term).url(using: authenticationProvider.authentication)

        print(url)
        let (data, _) = try await urlSession.data(for: .init(url: url))
        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse.subsonicResponse.searchResult2
    }

    func getAlbumList(type: AlbumListType) async throws -> [ListAlbum] {
        let url = try Path.albumList(type: type).url(using: authenticationProvider.authentication)

        print(url)
        let (data, _) = try await urlSession.data(for: .init(url: url))
        let albumListResponse = try JSONDecoder().decode(AlbumListResponse.self, from: data)
        return albumListResponse.subsonicResponse.albumList.album
    }

    func streamURL(id: String) throws -> URL {
        let url = try Path.stream(id: id).url(using: authenticationProvider.authentication)
        return url
    }

    func coverImageURL(song: Song) -> URL? {
        do {
            return try Path.coverImage(id: song.id).url(using: authenticationProvider.authentication)
        } catch {
            return nil
        }
    }
}
