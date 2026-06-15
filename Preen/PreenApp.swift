//
//  PreenApp.swift
//  Preen
//

import SwiftUI
import SwiftData

@main
struct PreenApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appEnvironment = AppEnvironment()

    var sharedModelContainer: ModelContainer = {
        do {
            return try PersistenceController.makeContainer()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(\.appEnvironment, appEnvironment)
                .task {
                    await appEnvironment.metricsService.startPolling()
                }
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 960, height: 640)
    }
}
