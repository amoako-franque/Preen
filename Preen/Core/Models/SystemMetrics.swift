import Foundation

struct SystemMetrics {
    var cpuUsage: Double = 0
    var ramUsed: UInt64 = 0
    var ramTotal: UInt64 = 0
    var diskFree: UInt64 = 0
    var diskTotal: UInt64 = 0
    var networkUp: Double = 0
    var networkDown: Double = 0
    var fanSpeed: [String: Int] = [:]
    var thermalState: ProcessInfo.ThermalState = .nominal
}
