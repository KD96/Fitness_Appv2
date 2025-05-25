//
//  MetricsSettingsView.swift
//  Fitness_Appv2
//
//  Created by Analytics & Crash Logging Integration
//

import SwiftUI

@available(iOS 13.0, *)
struct MetricsSettingsView: View {
    @StateObject private var metricsManager = MetricsManager.shared
    @State private var isUploading = false
    @State private var showingUploadAlert = false
    @State private var uploadMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // Metrics Collection Section
                Section {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Performance Analytics")
                                .font(.headline)
                            Text("Collect app performance data to improve your experience")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $metricsManager.isEnabled)
                            .onChange(of: metricsManager.isEnabled) { _, newValue in
                                metricsManager.setEnabled(newValue)
                            }
                    }
                    .padding(.vertical, 4)
                    
                    if metricsManager.isEnabled {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Crash Reports")
                                    .font(.headline)
                                Text("Automatically send crash reports to help fix issues")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Data Collection")
                } footer: {
                    if metricsManager.isEnabled {
                        Text("Analytics help us understand app performance and fix crashes. No personal workout data is included in these reports.")
                    } else {
                        Text("Analytics are disabled. We won't collect performance data or crash reports.")
                    }
                }
                
                // Current Status Section
                if metricsManager.isEnabled {
                    Section("Current Status") {
                        MetricsStatusRow(
                            icon: "clock",
                            title: "Last Upload",
                            value: formatLastUpload(),
                            color: .blue
                        )
                        
                        MetricsStatusRow(
                            icon: "tray.full",
                            title: "Pending Metrics",
                            value: "\(metricsManager.pendingMetricsCount)",
                            color: metricsManager.pendingMetricsCount > 0 ? .orange : .green
                        )
                        
                        let summary = metricsManager.getMetricsSummary()
                        
                        if summary.crashReportsCount > 0 {
                            MetricsStatusRow(
                                icon: "exclamationmark.triangle.fill",
                                title: "Crash Reports",
                                value: "\(summary.crashReportsCount)",
                                color: .red
                            )
                        }
                        
                        if summary.performanceMetricsCount > 0 {
                            MetricsStatusRow(
                                icon: "speedometer",
                                title: "Performance Metrics",
                                value: "\(summary.performanceMetricsCount)",
                                color: .blue
                            )
                        }
                    }
                    
                    // Actions Section
                    Section("Actions") {
                        Button(action: uploadMetrics) {
                            HStack {
                                if isUploading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "icloud.and.arrow.up")
                                        .foregroundColor(.blue)
                                }
                                
                                Text("Upload Pending Metrics")
                                    .foregroundColor(isUploading ? .secondary : .blue)
                                
                                Spacer()
                                
                                if metricsManager.pendingMetricsCount > 0 {
                                    Text("\(metricsManager.pendingMetricsCount)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.2))
                                        .foregroundColor(.orange)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .disabled(isUploading || metricsManager.pendingMetricsCount == 0)
                    }
                }
                
                // Information Section
                Section("About Analytics") {
                    InfoRow(
                        icon: "shield.checkered",
                        title: "Privacy First",
                        description: "Only technical data is collected. No personal information or workout details are included."
                    )
                    
                    InfoRow(
                        icon: "wrench.and.screwdriver",
                        title: "Improve Performance",
                        description: "Analytics help us identify and fix performance issues to make the app faster."
                    )
                    
                    InfoRow(
                        icon: "ant",
                        title: "Fix Bugs",
                        description: "Crash reports help us quickly identify and resolve issues that affect your experience."
                    )
                    
                    InfoRow(
                        icon: "trash",
                        title: "Data Retention",
                        description: "Analytics data is automatically deleted after 90 days."
                    )
                }
            }
            .navigationTitle("Analytics & Metrics")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Upload Status", isPresented: $showingUploadAlert) {
            Button("OK") { }
        } message: {
            Text(uploadMessage)
        }
    }
    
    private func formatLastUpload() -> String {
        guard let lastUpload = metricsManager.lastUploadDate else {
            return "Never"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpload, relativeTo: Date())
    }
    
    private func uploadMetrics() {
        isUploading = true
        
        Task {
            await metricsManager.uploadPendingMetrics()
            
            await MainActor.run {
                isUploading = false
                uploadMessage = "Metrics uploaded successfully!"
                showingUploadAlert = true
            }
        }
    }
}

// MARK: - Supporting Views

struct MetricsStatusRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
                .font(.system(.body, design: .monospaced))
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

@available(iOS 13.0, *)
struct MetricsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsSettingsView()
    }
} 