//
//  NaviplayApp.swift
//  Naviplay
//
//  Created by Martin Hartl on 22.04.23.
//

import SwiftUI
import KeychainAccess

@main
struct NaviplayApp: App {
    static let keychain = Keychain(service: "co.hartl.naviplay")
    @StateObject var appState: AppState = AppState(keychain: Self.keychain)

    init() {
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
        }
        .commands {
            CommandMenu("Control") {
                Button("Forward 10s") {
                    appState.forward(timeInterval: 10)
                }
                .keyboardShortcut(KeyboardShortcut("+", modifiers: .command))
                Button("Rewind 10s") {
                    appState.backward(timeInterval: 10)
                }
                .keyboardShortcut(KeyboardShortcut("-", modifiers: .command))
            }
        }
#if os(macOS)
        Settings {
            SettingsView(appState: appState)
        }
#endif
    }
}
