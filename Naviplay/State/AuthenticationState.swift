//
//  AuthenticationState.swift
//  Naviplay
//
//  Created by Martin Hartl on 30.04.23.
//

import Foundation
import KeychainAccess

public final class AuthenticationState: ObservableObject {
    static let usernameKey = "username"
    static let passwordKey = "password"
    static let urlKey = "url"

    private let keychain: Keychain

    init(keychain: Keychain) {
        self.keychain = keychain

        let username = try? keychain.get(Self.usernameKey) ?? ""
        let password = try? keychain.get(Self.passwordKey) ?? ""
        let urlString = try? keychain.get(Self.urlKey) ?? ""

        self.username = username ?? self.username
        self.password = password ?? self.password
        self.urlString = urlString ?? self.urlString
    }

    @Published var username: String = "" {
        didSet {
            try? keychain.set(username, key: Self.usernameKey)
        }
    }
    @Published var password: String = "" {
        didSet {
            try? keychain.set(password, key: Self.passwordKey)
        }
    }
    @Published var urlString: String = "" {
        didSet {
            try? keychain.set(urlString, key: Self.urlKey)
        }
    }
}

extension AuthenticationState: UsernamePasswordProvider {
    func getUsername() -> String {
        (try? keychain.get(Self.usernameKey) ?? "") ?? ""
    }

    func getPassword() -> String {
        (try? keychain.get(Self.passwordKey) ?? "") ?? ""
    }

    func getUrlString() -> String {
        (try? keychain.get(Self.urlKey) ?? "") ?? ""
    }
}
