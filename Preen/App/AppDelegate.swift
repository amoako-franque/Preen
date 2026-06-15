import AppKit
import Foundation
import os

private let logger = Logger(subsystem: PreenConstants.appBundleID, category: "AppDelegate")

/// AppKit bridge for Sparkle updates and system integration.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        registerHelper()
        configureSparkleIfAvailable()
    }

    private func registerHelper() {
        do {
            try HelperRegistrationService.registerIfNeeded()
            logger.info("Helper registration status: \(HelperRegistrationService.statusDescription, privacy: .public)")
        } catch {
            logger.error("Helper registration failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func configureSparkleIfAvailable() {
        #if canImport(Sparkle)
        Task { @MainActor in
            let updaterController = SPUStandardUpdaterController(
                startingUpdater: true,
                updaterDelegate: nil,
                userDriverDelegate: nil
            )
            _ = updaterController.updater
            logger.info("Sparkle updater configured")
        }
        #endif
    }
}

#if canImport(Sparkle)
import Sparkle
#endif
