//
//  Path.swift
//  Naviplay
//
//  Created by Martin Hartl on 23.04.23.
//

import Foundation

enum Path {
    static let format = "json"
    static let apiVersion = "1.16.1"
    static let client = "naviplay"

    case artists
    case artist(id: String)
    case album(id: String)
    case song(id: String)
    case stream(id: String)
    case coverImage(id: String)
    case search(term: String)
    case albumList(type: AlbumListType)

    var path: String {
        switch self {
        case .artists: return "rest/getArtists"
        case .artist: return "rest/getArtist"
        case .album: return "rest/getAlbum"
        case .song: return "rest/getSong"
        case .stream: return "rest/stream"
        case .coverImage: return "rest/getCoverArt"
        case .search: return "rest/search2"
        case .albumList: return "rest/getAlbumList"
        }
    }

    func url(using authentication: Authentication) throws -> URL {
        guard let baseURL = URL(string: authentication.baseURLString) else {
            throw ClientError.invalidURL
        }

        let url = baseURL.appending(path: path)

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw ClientError.invalidURL
        }

        components.queryItems = [
            .init(name: "u", value: authentication.user),
            .init(name: "t", value: authentication.token),
            .init(name: "s", value: authentication.salt),
            .init(name: "v", value: Self.apiVersion),
            .init(name: "f", value: Self.format),
            .init(name: "c", value: Self.client)
        ]

        switch self {
        case .artists:
            break
        case .artist(id: let id):
            components.queryItems?.append(.init(name: "id", value: id))
        case .album(id: let id):
            components.queryItems?.append(.init(name: "id", value: id))
        case .song(id: let id):
            fatalError()
        case .stream(id: let id):
            components.queryItems?.append(.init(name: "id", value: id))
        case .coverImage(id: let id):
            components.queryItems?.append(.init(name: "id", value: id))
        case .search(term: let term):
            components.queryItems?.append(.init(name: "query", value: term))
        case .albumList(type: let type):
            components.queryItems?.append(.init(name: "type", value: type.rawValue))
        }

        guard let url = components.url else {
            throw ClientError.invalidURL
        }

        return url
    }
}

enum AlbumListType: String {
    case newest
    case random
}
