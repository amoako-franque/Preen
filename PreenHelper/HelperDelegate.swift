import Foundation

final class HelperDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        guard HelperCodeSignatureValidator.validate(connection: connection) else {
            return false
        }

        connection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.exportedObject = HelperProtocolImpl()
        connection.resume()
        return true
    }
}
