import Foundation
import Security
import os

/// Validates XPC client code signatures for the privileged helper.
enum HelperCodeSignatureValidator {
    private static let logger = Logger(subsystem: PreenConstants.helperBundleID, category: "CodeSignature")

    static func validate(connection: NSXPCConnection, expectedBundleID: String = PreenConstants.appBundleID) -> Bool {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--disable-signature-check") {
            return true
        }
        #endif

        guard let token = connection.clientAuditToken() else {
            logger.error("Unable to read audit token for XPC client")
            return false
        }

        return validate(auditToken: token, expectedBundleID: expectedBundleID)
    }

    private static func validate(auditToken token: audit_token_t, expectedBundleID: String) -> Bool {
        var token = token
        var code: SecCode?
        let tokenData = withUnsafePointer(to: &token) { pointer in
            Data(bytes: pointer, count: MemoryLayout<audit_token_t>.size)
        }

        let attributes = [kSecGuestAttributeAudit as String: tokenData] as CFDictionary
        let copyStatus = SecCodeCopyGuestWithAttributes(nil, attributes, [], &code)
        guard copyStatus == errSecSuccess, let code else {
            logger.error("Failed to resolve SecCode for XPC client: \(copyStatus)")
            return false
        }

        var requirement: SecRequirement?
        let requirementString = "anchor apple generic and identifier \"\(expectedBundleID)\""
        let reqStatus = SecRequirementCreateWithString(
            requirementString as CFString,
            SecCSFlags(),
            &requirement
        )
        guard reqStatus == errSecSuccess, let requirement else {
            logger.error("Failed to create code requirement")
            return false
        }

        let valid = SecCodeCheckValidity(code, SecCSFlags(), requirement) == errSecSuccess
        if !valid {
            logger.error("Rejected unsigned or untrusted XPC client")
        }
        return valid
    }
}

private extension NSXPCConnection {
    func clientAuditToken() -> audit_token_t? {
        let selector = NSSelectorFromString("auditToken")
        guard responds(to: selector),
              let value = perform(selector)?.takeUnretainedValue()
        else {
            return nil
        }

        if let data = value as? Data, data.count == MemoryLayout<audit_token_t>.size {
            return data.withUnsafeBytes { $0.load(as: audit_token_t.self) }
        }

        if let nsValue = value as? NSValue {
            var token = audit_token_t()
            nsValue.getValue(&token)
            return token
        }

        return nil
    }
}
