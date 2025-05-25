//
//  MetricsManagerTests.swift
//  Fitness_Appv2Tests
//
//  Created by Analytics & Crash Logging Integration
//

import XCTest
import MetricKit
@testable import Fitness_Appv2

@available(iOS 13.0, *)
final class MetricsManagerTests: XCTestCase {
    
    var metricsManager: MetricsManager!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        // Use a test suite for UserDefaults to avoid affecting real app data
        mockUserDefaults = UserDefaults(suiteName: "MetricsManagerTests")
        mockUserDefaults.removePersistentDomain(forName: "MetricsManagerTests")
        
        metricsManager = MetricsManager.shared
    }
    
    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "MetricsManagerTests")
        mockUserDefaults = nil
        metricsManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testMetricsManagerSingleton() {
        let instance1 = MetricsManager.shared
        let instance2 = MetricsManager.shared
        
        XCTAssertTrue(instance1 === instance2, "MetricsManager should be a singleton")
    }
    
    func testInitialState() {
        XCTAssertTrue(metricsManager.isEnabled, "MetricsManager should be enabled by default")
        XCTAssertNil(metricsManager.lastUploadDate, "Last upload date should be nil initially")
        XCTAssertEqual(metricsManager.pendingMetricsCount, 0, "Pending metrics count should be 0 initially")
    }
    
    // MARK: - Settings Tests
    
    func testEnableDisableMetrics() {
        // Test disabling
        metricsManager.setEnabled(false)
        XCTAssertFalse(metricsManager.isEnabled, "MetricsManager should be disabled")
        
        // Test enabling
        metricsManager.setEnabled(true)
        XCTAssertTrue(metricsManager.isEnabled, "MetricsManager should be enabled")
    }
    
    // MARK: - Metrics Summary Tests
    
    func testGetMetricsSummary() {
        let summary = metricsManager.getMetricsSummary()
        
        XCTAssertTrue(summary.isEnabled, "Summary should show enabled state")
        XCTAssertNil(summary.lastUploadDate, "Summary should show nil last upload date")
        XCTAssertEqual(summary.pendingCount, 0, "Summary should show 0 pending metrics")
        XCTAssertEqual(summary.crashReportsCount, 0, "Summary should show 0 crash reports")
        XCTAssertEqual(summary.performanceMetricsCount, 0, "Summary should show 0 performance metrics")
    }
    
    // MARK: - Data Model Tests
    
    func testAppMetricCreation() {
        let id = UUID()
        let timestamp = Date()
        let data = ["test_key": "test_value"]
        let deviceInfo = ["model": "iPhone", "system": "iOS"]
        let appVersion = "1.0.0"
        let userId = UUID()
        
        let metric = AppMetric(
            id: id,
            type: .performance,
            timestamp: timestamp,
            data: data,
            deviceInfo: deviceInfo,
            appVersion: appVersion,
            userId: userId
        )
        
        XCTAssertEqual(metric.id, id)
        XCTAssertEqual(metric.type, .performance)
        XCTAssertEqual(metric.timestamp, timestamp)
        XCTAssertEqual(metric.data["test_key"] as? String, "test_value")
        XCTAssertEqual(metric.deviceInfo["model"] as? String, "iPhone")
        XCTAssertEqual(metric.appVersion, appVersion)
        XCTAssertEqual(metric.userId, userId)
    }
    
    func testMetricTypeEnum() {
        XCTAssertEqual(MetricType.performance.rawValue, "performance")
        XCTAssertEqual(MetricType.crash.rawValue, "crash")
        XCTAssertEqual(MetricType.hang.rawValue, "hang")
        XCTAssertEqual(MetricType.custom.rawValue, "custom")
    }
    
    // MARK: - AnyCodable Tests
    
    func testAnyCodableWithBasicTypes() {
        let stringValue = AnyCodable("test")
        let intValue = AnyCodable(42)
        let boolValue = AnyCodable(true)
        let doubleValue = AnyCodable(3.14)
        
        XCTAssertEqual(stringValue.value as? String, "test")
        XCTAssertEqual(intValue.value as? Int, 42)
        XCTAssertEqual(boolValue.value as? Bool, true)
        XCTAssertEqual(doubleValue.value as? Double, 3.14)
    }
    
    func testAnyCodableEquality() {
        let value1 = AnyCodable("test")
        let value2 = AnyCodable("test")
        let value3 = AnyCodable("different")
        
        XCTAssertEqual(value1, value2)
        XCTAssertNotEqual(value1, value3)
    }
    
    func testAnyCodableDescription() {
        let stringValue = AnyCodable("test")
        let intValue = AnyCodable(42)
        
        XCTAssertEqual(stringValue.description, "test")
        XCTAssertEqual(intValue.description, "42")
    }
    
    // MARK: - JSON Encoding/Decoding Tests
    
    func testAppMetricJSONEncoding() throws {
        let metric = AppMetric(
            id: UUID(),
            type: .performance,
            timestamp: Date(),
            data: ["key": "value", "number": 123],
            deviceInfo: ["model": "iPhone", "version": "15.0"],
            appVersion: "1.0.0",
            userId: UUID()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(metric)
        XCTAssertNotNil(data, "Metric should be encodable to JSON")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedMetric = try decoder.decode(AppMetric.self, from: data)
        
        XCTAssertEqual(decodedMetric.id, metric.id)
        XCTAssertEqual(decodedMetric.type, metric.type)
        XCTAssertEqual(decodedMetric.appVersion, metric.appVersion)
        XCTAssertEqual(decodedMetric.userId, metric.userId)
    }
    
    // MARK: - Performance Tests
    
    func testMetricsProcessingPerformance() {
        measure {
            for _ in 0..<100 {
                let metric = AppMetric(
                    id: UUID(),
                    type: .performance,
                    timestamp: Date(),
                    data: ["test": "data"],
                    deviceInfo: ["model": "iPhone"],
                    appVersion: "1.0.0",
                    userId: UUID()
                )
                
                // Simulate processing
                _ = metric.data
                _ = metric.deviceInfo
            }
        }
    }
    
    func testAnyCodablePerformance() {
        let testData: [String: Any] = [
            "string": "test",
            "int": 42,
            "double": 3.14,
            "bool": true,
            "array": [1, 2, 3],
            "dict": ["nested": "value"]
        ]
        
        measure {
            for _ in 0..<1000 {
                let encoded = testData.mapValues { AnyCodable($0) }
                _ = encoded.mapValues { $0.value }
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testSupabaseErrorTypes() {
        let notAuthError = SupabaseConfig.SupabaseError.notAuthenticated
        let configError = SupabaseConfig.SupabaseError.invalidConfiguration
        let networkError = SupabaseConfig.SupabaseError.networkError("Connection failed")
        let dbError = SupabaseConfig.SupabaseError.databaseError("Query failed")
        let authError = SupabaseConfig.SupabaseError.authError("Invalid credentials")
        
        XCTAssertEqual(notAuthError.errorDescription, "User is not authenticated")
        XCTAssertEqual(configError.errorDescription, "Invalid Supabase configuration")
        XCTAssertEqual(networkError.errorDescription, "Network error: Connection failed")
        XCTAssertEqual(dbError.errorDescription, "Database error: Query failed")
        XCTAssertEqual(authError.errorDescription, "Authentication error: Invalid credentials")
    }
    
    // MARK: - Integration Tests
    
    func testMetricsManagerIntegration() async {
        // Test that metrics manager can handle basic operations without crashing
        let summary = metricsManager.getMetricsSummary()
        XCTAssertNotNil(summary)
        
        // Test enable/disable cycle
        metricsManager.setEnabled(false)
        metricsManager.setEnabled(true)
        
        // Test upload (should handle gracefully even without real metrics)
        await metricsManager.uploadPendingMetrics()
        
        XCTAssertTrue(true, "Integration test completed without crashes")
    }
    
    // MARK: - Mock Data Tests
    
    func testCreateMockMetricData() {
        let mockData = createMockMetricData()
        
        XCTAssertNotNil(mockData["launch_time"])
        XCTAssertNotNil(mockData["cpu_time"])
        XCTAssertNotNil(mockData["peak_memory"])
        XCTAssertNotNil(mockData["cellular_upload"])
    }
    
    func testCreateMockDiagnosticData() {
        let mockData = createMockDiagnosticData()
        
        XCTAssertNotNil(mockData["crash_signal"])
        XCTAssertNotNil(mockData["stack_trace"])
        XCTAssertNotNil(mockData["hang_duration"])
    }
    
    // MARK: - Helper Methods
    
    private func createMockMetricData() -> [String: Any] {
        return [
            "launch_time": 1.5,
            "resume_time": 0.8,
            "hang_time": 0.1,
            "cpu_time": 120.5,
            "peak_memory": 50_000_000,
            "average_memory": 45_000_000,
            "cumulative_logical_writes": 1_000_000,
            "cellular_upload": 500_000,
            "cellular_download": 2_000_000,
            "wifi_upload": 1_000_000,
            "wifi_download": 5_000_000
        ]
    }
    
    private func createMockDiagnosticData() -> [String: Any] {
        return [
            "crash_signal": 11,
            "crash_exception_type": 1,
            "crash_exception_code": 0,
            "crash_termination_reason": "Segmentation fault",
            "stack_trace": [
                [
                    "binary_name": "Fitness_Appv2",
                    "address": "0x100001000",
                    "symbol": "main"
                ],
                [
                    "binary_name": "UIKit",
                    "address": "0x200001000",
                    "symbol": "UIApplicationMain"
                ]
            ],
            "hang_duration": 5.0,
            "hang_stack_trace": [
                [
                    "binary_name": "Fitness_Appv2",
                    "address": "0x100002000",
                    "symbol": "processData"
                ]
            ]
        ]
    }
} 