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
final class XPCClient: @unchecked Sendable {
    private let machServiceName: String
    private let lock = NSLock()
    private var connection: NSXPCConnection?

    init(machServiceName: String = PreenConstants.helperMachServiceName) {
        self.machServiceName = machServiceName
    }

    private func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }

    private func connectIfNeeded() {
        withLock {
            guard connection == nil else { return }
            let conn = NSXPCConnection(machServiceName: machServiceName)
            conn.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
            conn.invalidationHandler = { [weak self] in
                self?.withLock { self?.connection = nil }
            }
            conn.interruptionHandler = { [weak self] in
                self?.withLock { self?.connection = nil }
            }
            conn.resume()
            connection = conn
        }
    }

    func disconnect() {
        withLock {
            connection?.invalidate()
            connection = nil
        }
    }

    func getHelperVersion() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            connectIfNeeded()
            let proxy = withLock { () -> HelperProtocol? in
                connection?.remoteObjectProxyWithErrorHandler { error in
                    continuation.resume(throwing: error)
                } as? HelperProtocol
            }
            guard let proxy else {
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
            let proxy = withLock { () -> HelperProtocol? in
                connection?.remoteObjectProxyWithErrorHandler { error in
                    continuation.resume(throwing: error)
                } as? HelperProtocol
            }
            guard let proxy else {
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
