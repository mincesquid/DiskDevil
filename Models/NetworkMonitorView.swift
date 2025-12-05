//
//  NetworkMonitorView.swift
//  Mad Scientist
//

import SwiftUI

struct NetworkMonitorView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var monitor: NetworkMonitorService
    @State private var isMonitoring = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "network")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)

                Text("Network Monitor")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Monitor network connections and traffic")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if subscriptionManager.tier == .free {
                    Text("Premium Feature")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 20)

            // Traffic Summary
            HStack(spacing: 20) {
                TrafficCard(title: "Download", bytes: monitor.bytesIn, icon: "arrow.down.circle.fill", color: .green)
                TrafficCard(title: "Upload", bytes: monitor.bytesOut, icon: "arrow.up.circle.fill", color: .blue)
                TrafficCard(title: "Connections", value: "\(monitor.connections.count)", icon: "link", color: .orange)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)

            // Monitor Toggle
            HStack {
                VStack(alignment: .leading) {
                    Text("Network Monitoring")
                        .font(.headline)
                    Text(isMonitoring ? "Active" : "Disabled")
                        .font(.subheadline)
                        .foregroundColor(isMonitoring ? .green : .secondary)
                }
                Spacer()
                Toggle("", isOn: $isMonitoring)
                    .labelsHidden()
                    .onChange(of: isMonitoring, perform: { newValue in
                        if newValue {
                            startMonitoring()
                        } else {
                            stopMonitoring()
                        }
                    })
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)

            // Connections List
            if monitor.connections.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "network.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No active connections")
                        .font(.headline)
                    Text(isMonitoring ? "Waiting for network activity..." : "Enable monitoring to see connections")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List(monitor.connections) { connection in
                    NetworkConnectionRow(connection: connection)
                }
                .listStyle(.inset)
                .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .onDisappear {
            stopMonitoring()
        }
        .onAppear {
            if isMonitoring {
                startMonitoring()
            }
        }
    }

    private func startMonitoring() {
        monitor.start()
    }

    private func stopMonitoring() {
        monitor.stop()
    }
}

enum ConnectionStatus: String {
    case established = "Established"
    case listening = "Listening"
    case closed = "Closed"
    case timeWait = "Time Wait"

    var color: Color {
        switch self {
        case .established: return .green
        case .listening: return .blue
        case .closed: return .gray
        case .timeWait: return .orange
        }
    }
}

struct NetworkConnection: Identifiable {
    let id = UUID()
    let process: String
    let remoteAddress: String
    let port: Int
    let `protocol`: String
    let status: ConnectionStatus
    let timestamp = Date()
}

struct NetworkConnectionRow: View {
    let connection: NetworkConnection

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(connection.process)
                    .font(.headline)
                Text("\(connection.remoteAddress):\(connection.port)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(connection.protocol)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(connection.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(connection.status.color.opacity(0.2))
                    .foregroundColor(connection.status.color)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TrafficCard: View {
    let title: String
    var bytes: Int64?
    var value: String?
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            if let bytes = bytes {
                Text(formatBytes(bytes))
                    .font(.headline)
            } else if let value = value {
                Text(value)
                    .font(.headline)
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
}
