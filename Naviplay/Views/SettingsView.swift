//
//  SettingsView.swift
//  Naviplay
//
//  Created by Martin Hartl on 30.04.23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Form {
            TextField("URL", text: $appState.authenticationState.urlString, prompt: Text("URL"))
                .autocorrectionDisabled()
            TextField("Username", text: $appState.authenticationState.username, prompt: Text("Username"))
                .textContentType(.username)
                .autocorrectionDisabled()
            SecureField("Password", text: $appState.authenticationState.password, prompt: Text("Password"))
                .textContentType(.password)
                .autocorrectionDisabled()
        }
        .padding()
        .frame(minWidth: 120, maxWidth: 250)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(appState: .mock)
    }
}
