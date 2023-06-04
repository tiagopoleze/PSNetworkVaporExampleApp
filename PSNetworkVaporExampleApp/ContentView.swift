//
//  ContentView.swift
//  PSNetworkVaporExampleApp
//
//  Created by Tiago Ferreira on 03/06/2023.
//

import SwiftUI
import PSNetwork
import PSNetworkVaporSharedLibrary

struct ContentView: View {
    @State private var isMocked = false

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    GetView()
                } label: {
                    Text("Using server")
                }
                NavigationLink {
                    GetView(isMocked: true)
                } label: {
                    Text("Mocked")
                }

            }
        }
    }
}
