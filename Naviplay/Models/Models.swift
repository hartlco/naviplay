//
//  Artist.swift
//  Naviplay
//
//  Created by Martin Hartl on 22.04.23.
//

import Foundation

public struct ListArtist: Codable, Identifiable, Hashable {
    public var id: String
    var name: String
}

public struct DetailArtist: Codable, Identifiable, Hashable {
    public var id: String
    var name: String
    var album: [ListAlbum]
}

public struct ArtistListItem: Codable, Identifiable {
    public var id: String {
        name
    }

    var name: String
    var artist: [ListArtist]
}

public struct ArtistListResponse: Codable {
    struct SubSonicResponse: Codable {
        struct Artists: Codable {
            var index: [ArtistListItem]
        }

        var artists: Artists
    }

    var subsonicResponse: SubSonicResponse

    private enum CodingKeys : String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

public struct ArtistResponse: Codable {
    struct SubSonicResponse: Codable {
        var artist: DetailArtist
    }

    var subsonicResponse: SubSonicResponse

    private enum CodingKeys : String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

public struct AlbumResponse: Codable {
    struct SubSonicResponse: Codable {
        var album: DetailAlbum
    }

    var subsonicResponse: SubSonicResponse

    private enum CodingKeys : String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

public struct SearchResponse: Codable {
    struct SubSonicResponse: Codable {
        var searchResult2: SearchResult
    }

    var subsonicResponse: SubSonicResponse

    private enum CodingKeys : String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

struct SearchResult: Codable {
    var artist: [ListArtist]?
    var song: [Song]?
    var album: [ListAlbum]?
}

struct AlbumListResponse: Codable {
    struct SubSonicResponse: Codable {
        var albumList: AlbumListResult
    }

    var subsonicResponse: SubSonicResponse

    private enum CodingKeys : String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

struct AlbumListResult: Codable {
    var album: [ListAlbum]
}

public struct ListAlbum: Codable, Identifiable, Hashable {
    var artistId: String
    public var id: String
    var name: String
}

public struct DetailAlbum: Codable, Identifiable, Hashable {
    var artistId: String
    public var id: String
    var name: String
    var song: [Song]
}

public struct Song: Codable, Identifiable, Hashable {
    public var id: String
    var title: String
    var album: String
    var artist: String
    var track: Int
    var duration: TimeInterval

    static var mock: Song {
        Song(id: "1", title: "Song", album: "Album", artist: "Artist", track: 1, duration: 42.0)
    }
}
