import Foundation
import ServiceManagement
import os

enum HelperRegistrationError: Error, LocalizedError {
    case registrationFailed(String)

    var errorDescription: String? {
        switch self {
        case .registrationFailed(let message):
            message
        }
    }
}

/// Registers and manages the privileged PreenHelper via SMAppService.
enum HelperRegistrationService {
    private static let logger = Logger(subsystem: PreenConstants.appBundleID, category: "HelperRegistration")

    static var plistName: String {
        "\(PreenConstants.helperBundleID).plist"
    }

    static var service: SMAppService {
        SMAppService.daemon(plistName: plistName)
    }

    static var statusDescription: String {
        switch service.status {
        case .enabled:
            "Registered and enabled"
        case .requiresApproval:
            "Registered — requires approval in System Settings"
        case .notRegistered:
            "Not registered"
        case .notFound:
            "Helper plist not found in app bundle"
        @unknown default:
            "Unknown status"
        }
    }

    static func registerIfNeeded() throws {
        switch service.status {
        case .enabled, .requiresApproval:
            logger.info("Helper already registered: \(statusDescription, privacy: .public)")
            return
        case .notRegistered, .notFound:
            logger.info("Registering privileged helper…")
            try service.register()
            logger.info("Helper registration submitted")
        @unknown default:
            try service.register()
        }
    }

    static func unregister() throws {
        try service.unregister()
    }
}
