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
    private let isMocked: Bool

    init(text: Binding<String>, isMocked: Bool = false) {
        _text = text
        self.isMocked = isMocked
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

                if isMocked {
                    let networkExchange: PSNetwork.Mock.NetworkExchange<PostOutput>
                    networkExchange = MyMockable.mockNetworkExchange(
                        request: try request.urlRequest(),
                        statusCode: .ok,
                        mockData: PostOutputMocked(rawValue: "post.json")!)
                    postOutput = networkExchange.response?.data

                } else {
                    postOutput = try await manager.request(request)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        .navigationTitle("Post Request")
    }
}

struct MyMockable: Mockable {}
extension PostOutput: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }

    public static func == (lhs: PostOutput, rhs: PostOutput) -> Bool {
        lhs.id == rhs.id
    }
}
struct PostOutputMocked: MockableData {
    var rawValue: String

    public typealias ReturnType = PostOutput
    public typealias RawValue = String

    public var bundle: Bundle { .main }
    public var error: PSNetwork.Error? { nil }

    init?(rawValue: String) {
        self.rawValue = rawValue
    }
}
