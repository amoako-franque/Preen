import SwiftUI

struct DashboardView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @State private var helperRegistrationStatus = HelperRegistrationService.statusDescription
    @State private var helperConnectionStatus = "Not tested"
    @State private var helperVersion = "—"

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: PreenSpacing.lg) {
                header
                foundationCard
                Spacer()
            }
            .padding(PreenSpacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(PreenColors.background)
            .navigationTitle("Dashboard")
        }
        .onAppear {
            helperRegistrationStatus = HelperRegistrationService.statusDescription
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PreenSpacing.sm) {
            Label("Preen", systemImage: PreenIcons.dashboard)
                .font(PreenTypography.largeTitle)
            Text("Privacy-first Mac system utility")
                .font(PreenTypography.body)
                .foregroundStyle(PreenColors.secondaryText)
        }
    }

    private var foundationCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: PreenSpacing.sm) {
                statusRow("SwiftData schema", value: "Initialized", icon: PreenIcons.safe, color: PreenColors.safe)
                statusRow("Helper registration", value: helperRegistrationStatus, icon: PreenIcons.helper, color: PreenColors.caution)
                statusRow("XPC connection", value: helperConnectionStatus, icon: PreenIcons.sparkline, color: PreenColors.secondaryText)
                statusRow("Helper version", value: helperVersion, icon: PreenIcons.settings, color: PreenColors.secondaryText)

                HStack(spacing: PreenSpacing.sm) {
                    Button("Register Helper") {
                        registerHelper()
                    }
                    Button("Test XPC Connection") {
                        Task { await testHelperConnection() }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Text("Phase 0 — Foundation")
                .font(PreenTypography.title)
        }
    }

    private func statusRow(_ title: String, value: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: PreenSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PreenTypography.body)
                Text(value)
                    .font(PreenTypography.caption)
                    .foregroundStyle(PreenColors.secondaryText)
            }
        }
    }

    private func registerHelper() {
        do {
            try HelperRegistrationService.registerIfNeeded()
            helperRegistrationStatus = HelperRegistrationService.statusDescription
        } catch {
            helperRegistrationStatus = error.localizedDescription
        }
    }

    private func testHelperConnection() async {
        helperConnectionStatus = "Connecting…"
        do {
            let version = try await appEnvironment.xpcClient.getHelperVersion()
            helperVersion = version
            let pong = try await appEnvironment.xpcClient.ping()
            helperConnectionStatus = "Connected (\(pong))"
        } catch {
            helperConnectionStatus = error.localizedDescription
            helperVersion = "—"
        }
    }
}

#Preview {
    DashboardView()
        .environment(\.appEnvironment, AppEnvironment())
}
