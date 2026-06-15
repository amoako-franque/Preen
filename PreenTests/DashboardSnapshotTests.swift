import AppKit
import SnapshotTesting
import SwiftUI
import Testing
@testable import Preen

@MainActor
struct DashboardSnapshotTests {
    @Test func dashboardRenders() async throws {
        let isRecording = ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"

        let view = DashboardView()
            .environment(\.appEnvironment, AppEnvironment())
            .frame(width: 960, height: 640)

        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = CGRect(x: 0, y: 0, width: 960, height: 640)

        let failure = assertSnapshot(
            of: hostingView,
            as: .image,
            record: isRecording
        )

        if let failure {
            if isRecording {
                Issue.record("Snapshot recorded. Re-run without RECORD_SNAPSHOTS to verify.")
            } else {
                throw failure
            }
        }
    }
}
