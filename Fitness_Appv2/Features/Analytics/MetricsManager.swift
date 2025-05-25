//
//  MetricsManager.swift
//  Fitness_Appv2
//
//  Created by Analytics & Crash Logging Integration
//

import Foundation
import MetricKit
import Supabase

/// Manager for collecting and uploading app metrics and crash logs
@available(iOS 13.0, *)
class MetricsManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    static let shared = MetricsManager()
    
    // MARK: - Properties
    private let supabaseClient: SupabaseClient
    private let userDefaults = UserDefaults.standard
    
    @Published var isEnabled = true
    @Published var lastUploadDate: Date?
    @Published var pendingMetricsCount = 0
    
    // Storage keys
    private let enabledKey = "MetricsManager_Enabled"
    private let lastUploadKey = "MetricsManager_LastUpload"
    private let pendingMetricsKey = "MetricsManager_PendingMetrics"
    
    // MARK: - Initialization
    private override init() {
        self.supabaseClient = SupabaseConfig.client
        super.init()
        
        loadSettings()
        setupMetricKit()
    }
    
    // MARK: - Setup
    private func setupMetricKit() {
        guard isEnabled else { return }
        
        // Subscribe to MetricKit
        MXMetricManager.shared.add(self)
        
        print("📊 MetricsManager: MetricKit subscription active")
    }
    
    private func loadSettings() {
        isEnabled = userDefaults.bool(forKey: enabledKey)
        
        if let lastUpload = userDefaults.object(forKey: lastUploadKey) as? Date {
            lastUploadDate = lastUpload
        }
        
        pendingMetricsCount = getPendingMetrics().count
    }
    
    // MARK: - Public Methods
    
    /// Enable or disable metrics collection
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        userDefaults.set(enabled, forKey: enabledKey)
        
        if enabled {
            setupMetricKit()
        } else {
            MXMetricManager.shared.remove(self)
        }
    }
    
    /// Manually trigger upload of pending metrics
    func uploadPendingMetrics() async {
        let metrics = getPendingMetrics()
        guard !metrics.isEmpty else { return }
        
        for metric in metrics {
            await uploadMetric(metric)
        }
        
        clearPendingMetrics()
        await MainActor.run {
            lastUploadDate = Date()
            userDefaults.set(lastUploadDate, forKey: lastUploadKey)
            pendingMetricsCount = 0
        }
    }
    
    /// Get metrics summary for UI display
    func getMetricsSummary() -> MetricsSummary {
        let pending = getPendingMetrics()
        
        return MetricsSummary(
            isEnabled: isEnabled,
            lastUploadDate: lastUploadDate,
            pendingCount: pending.count,
            crashReportsCount: pending.filter { $0.type == .crash }.count,
            performanceMetricsCount: pending.filter { $0.type == .performance }.count
        )
    }
}

// MARK: - MXMetricManagerSubscriber
@available(iOS 13.0, *)
extension MetricsManager: MXMetricManagerSubscriber {
    
    func didReceive(_ payloads: [MXMetricPayload]) {
        print("📊 MetricsManager: Received \(payloads.count) metric payloads")
        
        for payload in payloads {
            processMetricPayload(payload)
        }
    }
    
    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        print("🚨 MetricsManager: Received \(payloads.count) diagnostic payloads")
        
        for payload in payloads {
            processDiagnosticPayload(payload)
        }
    }
}

// MARK: - Payload Processing
@available(iOS 13.0, *)
extension MetricsManager {
    
    private func processMetricPayload(_ payload: MXMetricPayload) {
        let metric = AppMetric(
            id: UUID(),
            type: .performance,
            timestamp: payload.timeStampEnd,
            data: extractMetricData(from: payload),
            deviceInfo: getDeviceInfo(),
            appVersion: getAppVersion(),
            userId: SupabaseConfig.currentUserId
        )
        
        savePendingMetric(metric)
    }
    
    private func processDiagnosticPayload(_ payload: MXDiagnosticPayload) {
        let metric = AppMetric(
            id: UUID(),
            type: .crash,
            timestamp: payload.timeStampEnd,
            data: extractDiagnosticData(from: payload),
            deviceInfo: getDeviceInfo(),
            appVersion: getAppVersion(),
            userId: SupabaseConfig.currentUserId
        )
        
        savePendingMetric(metric)
        
        // Auto-upload crash reports immediately
        Task {
            await uploadMetric(metric)
        }
    }
    
    private func extractMetricData(from payload: MXMetricPayload) -> [String: Any] {
        var data: [String: Any] = [:]
        
        // App launch metrics
        if let launchMetrics = payload.applicationLaunchMetrics {
            data["launch_time"] = launchMetrics.histogrammedTimeToFirstDraw.averageValue
            data["resume_time"] = launchMetrics.histogrammedApplicationResumeTime.averageValue
        }
        
        // App responsiveness
        if let responsivenessMetrics = payload.applicationResponsivenessMetrics {
            data["hang_time"] = responsivenessMetrics.histogrammedApplicationHangTime.averageValue
        }
        
        // CPU metrics
        if let cpuMetrics = payload.cpuMetrics {
            data["cpu_time"] = cpuMetrics.cumulativeCPUTime.doubleValue
        }
        
        // Memory metrics
        if let memoryMetrics = payload.memoryMetrics {
            data["peak_memory"] = memoryMetrics.peakMemoryUsage.doubleValue
            data["average_memory"] = memoryMetrics.averageSuspendedMemory?.doubleValue
        }
        
        // Disk I/O metrics
        if let diskMetrics = payload.diskIOMetrics {
            data["cumulative_logical_writes"] = diskMetrics.cumulativeLogicalWrites.doubleValue
        }
        
        // Network metrics
        if let networkMetrics = payload.networkTransferMetrics {
            data["cellular_upload"] = networkMetrics.cumulativeCellularUpload.doubleValue
            data["cellular_download"] = networkMetrics.cumulativeCellularDownload.doubleValue
            data["wifi_upload"] = networkMetrics.cumulativeWiFiUpload.doubleValue
            data["wifi_download"] = networkMetrics.cumulativeWiFiDownload.doubleValue
        }
        
        return data
    }
    
    private func extractDiagnosticData(from payload: MXDiagnosticPayload) -> [String: Any] {
        var data: [String: Any] = [:]
        
        // Crash diagnostics
        if let crashDiagnostics = payload.crashDiagnostics {
            for crash in crashDiagnostics {
                data["crash_signal"] = crash.signal
                data["crash_exception_type"] = crash.exceptionType?.rawValue
                data["crash_exception_code"] = crash.exceptionCode
                data["crash_termination_reason"] = crash.terminationReason
                data["crash_virtual_memory_region_info"] = crash.virtualMemoryRegionInfo
                
                // Stack trace (first few frames)
                if let callStack = crash.callStackTree.callStacks.first {
                    let frames = callStack.callStackRootFrames.prefix(10).map { frame in
                        [
                            "binary_name": frame.binaryName,
                            "address": frame.address,
                            "symbol": frame.symbol ?? "unknown"
                        ]
                    }
                    data["stack_trace"] = frames
                }
            }
        }
        
        // Hang diagnostics
        if let hangDiagnostics = payload.hangDiagnostics {
            for hang in hangDiagnostics {
                data["hang_duration"] = hang.hangDuration.doubleValue
                
                if let callStack = hang.callStackTree.callStacks.first {
                    let frames = callStack.callStackRootFrames.prefix(5).map { frame in
                        [
                            "binary_name": frame.binaryName,
                            "address": frame.address,
                            "symbol": frame.symbol ?? "unknown"
                        ]
                    }
                    data["hang_stack_trace"] = frames
                }
            }
        }
        
        // CPU exception diagnostics
        if let cpuExceptionDiagnostics = payload.cpuExceptionDiagnostics {
            for cpuException in cpuExceptionDiagnostics {
                data["cpu_exception_duration"] = cpuException.totalCPUTime.doubleValue
                data["cpu_exception_threshold"] = cpuException.totalSampledTime.doubleValue
            }
        }
        
        // Disk write exception diagnostics
        if let diskWriteExceptionDiagnostics = payload.diskWriteExceptionDiagnostics {
            for diskException in diskWriteExceptionDiagnostics {
                data["disk_writes_caused"] = diskException.totalWritesCaused.doubleValue
            }
        }
        
        return data
    }
}

// MARK: - Data Management
@available(iOS 13.0, *)
extension MetricsManager {
    
    private func savePendingMetric(_ metric: AppMetric) {
        var pending = getPendingMetrics()
        pending.append(metric)
        
        do {
            let data = try JSONEncoder().encode(pending)
            userDefaults.set(data, forKey: pendingMetricsKey)
            
            DispatchQueue.main.async {
                self.pendingMetricsCount = pending.count
            }
        } catch {
            print("❌ MetricsManager: Failed to save pending metric: \(error)")
        }
    }
    
    private func getPendingMetrics() -> [AppMetric] {
        guard let data = userDefaults.data(forKey: pendingMetricsKey),
              let metrics = try? JSONDecoder().decode([AppMetric].self, from: data) else {
            return []
        }
        return metrics
    }
    
    private func clearPendingMetrics() {
        userDefaults.removeObject(forKey: pendingMetricsKey)
    }
    
    private func uploadMetric(_ metric: AppMetric) async {
        do {
            let metricData: [String: AnyJSON] = [
                "id": AnyJSON(metric.id.uuidString),
                "type": AnyJSON(metric.type.rawValue),
                "timestamp": AnyJSON(metric.timestamp.ISO8601Format()),
                "data": AnyJSON(metric.data),
                "device_info": AnyJSON(metric.deviceInfo),
                "app_version": AnyJSON(metric.appVersion),
                "user_id": AnyJSON(metric.userId?.uuidString)
            ]
            
            try await supabaseClient.database
                .from("app_metrics")
                .insert(metricData)
                .execute()
            
            print("✅ MetricsManager: Uploaded metric \(metric.id)")
            
        } catch {
            print("❌ MetricsManager: Failed to upload metric: \(error)")
        }
    }
}

// MARK: - Helper Methods
@available(iOS 13.0, *)
extension MetricsManager {
    
    private func getDeviceInfo() -> [String: Any] {
        return [
            "model": UIDevice.current.model,
            "system_name": UIDevice.current.systemName,
            "system_version": UIDevice.current.systemVersion,
            "identifier_for_vendor": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        ]
    }
    
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        return "\(version) (\(build))"
    }
}

// MARK: - Data Models

struct AppMetric: Codable {
    let id: UUID
    let type: MetricType
    let timestamp: Date
    let data: [String: Any]
    let deviceInfo: [String: Any]
    let appVersion: String
    let userId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case id, type, timestamp, data, deviceInfo, appVersion, userId
    }
    
    init(id: UUID, type: MetricType, timestamp: Date, data: [String: Any], deviceInfo: [String: Any], appVersion: String, userId: UUID?) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.data = data
        self.deviceInfo = deviceInfo
        self.appVersion = appVersion
        self.userId = userId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(MetricType.self, forKey: .type)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        appVersion = try container.decode(String.self, forKey: .appVersion)
        userId = try container.decodeIfPresent(UUID.self, forKey: .userId)
        
        // Decode Any dictionaries
        data = try container.decode([String: AnyCodable].self, forKey: .data).mapValues { $0.value }
        deviceInfo = try container.decode([String: AnyCodable].self, forKey: .deviceInfo).mapValues { $0.value }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encodeIfPresent(userId, forKey: .userId)
        
        // Encode Any dictionaries
        try container.encode(data.mapValues { AnyCodable($0) }, forKey: .data)
        try container.encode(deviceInfo.mapValues { AnyCodable($0) }, forKey: .deviceInfo)
    }
}

enum MetricType: String, Codable {
    case performance = "performance"
    case crash = "crash"
    case hang = "hang"
    case custom = "custom"
}

struct MetricsSummary {
    let isEnabled: Bool
    let lastUploadDate: Date?
    let pendingCount: Int
    let crashReportsCount: Int
    let performanceMetricsCount: Int
} 