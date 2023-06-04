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
    @EnvironmentObject private var manager: PSNetwork.NetworkManager
    @StateObject private var viewModel: ContentViewModel

    @State private var showChangeName = false
    @State private var text = ""

    init(viewModel: ContentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            AsyncContentView(source: viewModel) { model in
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    Text("Hello, \(model.name)!")

                    Button {
                        withAnimation {
                            showChangeName.toggle()
                        }
                        if !text.isEmpty { text = "" }
                    } label: {
                        Text(showChangeName ? "Cancel" : "Change name")
                    }
                    .padding()

                    if showChangeName {
                        VStack {
                            TextField("New Name", text: $text)
                            NavigationLink {
                                PostView(text: $text)
                            } label: {
                                Text("Confirm")
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("PSNetwork+Vapor")
        }
    }
}

class ContentViewModel: LoadableObject {
    @Published var state: LoadingState<PSNetworkVaporSharedLibrary.GetOutput> = .idle
    private let manager: PSNetwork.NetworkManager

    init(manager: PSNetwork.NetworkManager) {
        self.manager = manager
    }

    @MainActor
    func load() {
        state = .loading
        Task {
            do {
                let model = try await manager.request(GetRequest())
                state = .loaded(model)
            } catch {
                state = .failed(error)
            }
        }
    }
}
