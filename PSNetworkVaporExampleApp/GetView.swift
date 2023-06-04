//
//  GetView.swift
//  PSNetworkVaporExampleApp
//
//  Created by Tiago Ferreira on 04/06/2023.
//

import SwiftUI
import PSNetwork
import PSNetworkVaporSharedLibrary

struct GetView: View {
    @EnvironmentObject private var manager: PSNetwork.NetworkManager
    @State private var showChangeName = false
    @State private var text: String = ""
    @State private var model: GetOutput?
    private let isMocked: Bool

    init(isMocked: Bool = false) {
        self.isMocked = isMocked
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, \(model?.name ?? "No name")!")

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
                        PostView(text: $text, isMocked: isMocked)
                    } label: {
                        Text("Confirm")
                    }
                }
            }
        }
        .padding()
        .task {
            var request = GetRequest()
            do {
                if isMocked {
                    let network: PSNetwork.Mock.NetworkExchange<GetOutput>
                    network = MyMockable.mockNetworkExchange(request: try request.urlRequest(), statusCode: .ok, mockData: GetRequestMocked(rawValue: "get.json"))
                    model = network.response?.data
                } else {
                    model = try await manager.request(request)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct GetView_Previews: PreviewProvider {
    static var previews: some View {
        GetView()
    }
}


extension GetOutput: Hashable {
    public static func == (lhs: GetOutput, rhs: GetOutput) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
struct GetRequestMocked: MockableData {
    typealias ReturnType = GetOutput
    typealias RawValue = String

    var bundle: Bundle { .main }
    var error: PSNetwork.Error? { nil }
    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
