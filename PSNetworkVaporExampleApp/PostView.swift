//
//  PostView.swift
//  PSNetworkVaporExampleApp
//
//  Created by Tiago Ferreira on 04/06/2023.
//

import SwiftUI
import PSNetwork
import PSNetworkVaporSharedLibrary

struct PostView: View {
    @EnvironmentObject private var manager: PSNetwork.NetworkManager
    @Binding private var text: String
    @State private var postOutput: PostOutput?

    init(text: Binding<String>) {
        _text = text
    }

    var body: some View {
        VStack {
            Text("ID: \(postOutput?.id ?? "No Id")")
            Text("Name: \(postOutput?.name ?? "No name")")
        }
        .task {
            do {
                var request = PostRequest()
                request.bodyParameter = .init(name: text)
                postOutput = try await manager.request(request)
            } catch {
                print(error.localizedDescription)
            }
        }
        .navigationTitle("Post Request")
    }
}
