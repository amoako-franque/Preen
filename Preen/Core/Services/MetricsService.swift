import Foundation
import Darwin
import os

private let logger = Logger(subsystem: PreenConstants.appBundleID, category: "MetricsService")

actor MetricsService {
    private var previousTicks: host_cpu_load_info_data_t?
    private var pollingTask: Task<Void, Never>?

    private(set) var metrics = SystemMetrics()

    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.poll()
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func poll() {
        let cpu = readCPU()
        let thermal = ProcessInfo.processInfo.thermalState
        metrics = SystemMetrics(
            cpuUsage: cpu,
            ramUsed: 0,
            ramTotal: 0,
            diskFree: 0,
            diskTotal: 0,
            networkUp: 0,
            networkDown: 0,
            fanSpeed: [:],
            thermalState: thermal
        )
        logger.debug("CPU usage: \(cpu, privacy: .public)%")
    }

    private func readCPU() -> Double {
        var cpuLoad = host_cpu_load_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &cpuLoad) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics64(
                    mach_host_self(),
                    HOST_CPU_LOAD_INFO,
                    intPtr,
                    &count
                )
            }
        }

        guard result == KERN_SUCCESS else {
            logger.error("host_statistics64 failed: \(result)")
            return 0
        }

        let user = Double(cpuLoad.cpu_ticks.0)
        let system = Double(cpuLoad.cpu_ticks.1)
        let idle = Double(cpuLoad.cpu_ticks.2)
        let nice = Double(cpuLoad.cpu_ticks.3)

        let totalTicks = user + system + idle + nice
        let activeTicks = user + system + nice

        if let prev = previousTicks {
            let prevUser = Double(prev.cpu_ticks.0)
            let prevSystem = Double(prev.cpu_ticks.1)
            let prevIdle = Double(prev.cpu_ticks.2)
            let prevNice = Double(prev.cpu_ticks.3)

            let prevTotal = prevUser + prevSystem + prevIdle + prevNice
            let prevActive = prevUser + prevSystem + prevNice

            let deltaTotal = totalTicks - prevTotal
            let deltaActive = activeTicks - prevActive

            previousTicks = cpuLoad

            guard deltaTotal > 0 else { return 0 }
            return (deltaActive / deltaTotal) * 100
        }

        previousTicks = cpuLoad

        guard totalTicks > 0 else { return 0 }
        return (activeTicks / totalTicks) * 100
    }
}
