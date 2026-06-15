import Foundation

/// XPC protocol shared between Preen.app and PreenHelper.
@objc protocol HelperProtocol {
    func getHelperVersion(with reply: @escaping (String) -> Void)
    func ping(with reply: @escaping (String) -> Void)
}

/// Implemented by PreenHelper; exported to the app via XPC.
@objc final class HelperProtocolImpl: NSObject, HelperProtocol {
    func getHelperVersion(with reply: @escaping (String) -> Void) {
        reply(PreenConstants.helperVersion)
    }

    func ping(with reply: @escaping (String) -> Void) {
        reply("pong")
    }
}
