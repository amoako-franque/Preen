import Foundation

enum XPCClientError: Error, LocalizedError {
    case helperUnavailable
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .helperUnavailable:
            "PreenHelper is not installed or not running."
        case .invalidResponse:
            "PreenHelper returned an unexpected response."
        }
    }
}

/// Connects to the privileged helper over XPC.
actor XPCClient {
    private let machServiceName: String
    private var connection: NSXPCConnection?

    init(machServiceName: String = PreenConstants.helperMachServiceName) {
        self.machServiceName = machServiceName
    }

    nonisolated func connect() {
        Task { await connectIfNeeded() }
    }

    private func connectIfNeeded() {
        guard connection == nil else { return }

        let connection = NSXPCConnection(machServiceName: machServiceName)
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.invalidationHandler = { [weak self] in
            Task { await self?.handleDisconnection() }
        }
        connection.interruptionHandler = { [weak self] in
            Task { await self?.handleDisconnection() }
        }
        connection.resume()
        self.connection = connection
    }

    private func handleDisconnection() {
        connection = nil
    }

    func disconnect() {
        connection?.invalidate()
        connection = nil
    }

    func getHelperVersion() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            connectIfNeeded()
            guard let proxy = connection?.remoteObjectProxyWithErrorHandler({ error in
                continuation.resume(throwing: error)
            }) as? HelperProtocol else {
                continuation.resume(throwing: XPCClientError.helperUnavailable)
                return
            }

            proxy.getHelperVersion { version in
                continuation.resume(returning: version)
            }
        }
    }

    func ping() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            connectIfNeeded()
            guard let proxy = connection?.remoteObjectProxyWithErrorHandler({ error in
                continuation.resume(throwing: error)
            }) as? HelperProtocol else {
                continuation.resume(throwing: XPCClientError.helperUnavailable)
                return
            }

            proxy.ping { response in
                guard response == "pong" else {
                    continuation.resume(throwing: XPCClientError.invalidResponse)
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }
}
