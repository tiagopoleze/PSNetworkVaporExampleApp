//
//  PSNetworkVaporExampleAppApp.swift
//  PSNetworkVaporExampleApp
//
//  Created by Tiago Ferreira on 03/06/2023.
//

import SwiftUI
import PSNetwork

@main
struct PSNetworkVaporExampleAppApp: App {
    @StateObject private var networkManager: PSNetwork.NetworkManager

    init() {
        _networkManager = StateObject(wrappedValue: PSNetwork.NetworkManager())
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init(manager: networkManager))
                .environmentObject(networkManager)
        }
    }
}
