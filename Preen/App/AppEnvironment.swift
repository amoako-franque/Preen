import SwiftUI

/// Dependency injection container for services. Injected into the SwiftUI environment.
@Observable
final class AppEnvironment {
    let xpcClient: XPCClient
    let metricsService: MetricsService

    init(
        xpcClient: XPCClient = XPCClient(),
        metricsService: MetricsService = MetricsService()
    ) {
        self.xpcClient = xpcClient
        self.metricsService = metricsService
    }
}

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppEnvironment()
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
