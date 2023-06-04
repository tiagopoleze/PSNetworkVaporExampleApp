import SwiftUI
import Combine

struct AsyncContentView<Source: LoadableObject, Content: View>: View {
    @ObservedObject var source: Source
    var content: (Source.Output) -> Content

    @State private var first = true
    let retryHandler: (() -> Void)?

    public init(
        source: Source,
        @ViewBuilder content: @escaping (Source.Output) -> Content,
        retryHandler: (() -> Void)? = nil
    ) {
        self.source = source
        self.content = content
        self.retryHandler = retryHandler
    }

    public var body: some View {
        switch source.state {
        case .idle:
            Color.clear.onAppear(perform: source.load)
        case .loading:
            ProgressView()
        case .failed(let error):
            AsyncErrorView(error: error, retryHandler: first ? source.load : retryHandler)
                .onAppear { first.toggle() }
        case .loaded(let output):
            content(output)
        }
    }
}

struct AsyncErrorView: View {
    @State var error: Error?
    var retryHandler: (() -> Void)?

    var body: some View {
        Text(error?.localizedDescription ?? "")
            .errorAlert(error: $error, buttonAction: retryHandler)
    }
}

public protocol LoadableObject: ObservableObject {
    associatedtype Output
    var state: LoadingState<Output> { get }
    func load()
}

public enum LoadingState<Value> {
    case idle
    case loading
    case failed(Error)
    case loaded(Value)
}

extension View {
    func errorAlert(
        error: Binding<Error?>,
        buttonTitle: String = "OK",
        buttonAction: (() -> Void)? = nil
    ) -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
                buttonAction?()
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}

private struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}
