import SwiftUI

struct TelemetryInspectorView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var inspector = TelemetryService()

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                Text("Telemetry Inspector")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Review diagnostics, analytics, and crash reporting settings")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)

            settingsSection
            eventsSection

            Spacer()
        }
        .padding()
        .onAppear {
            inspector.refresh()
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)

            if inspector.settings.isEmpty {
                Text("No telemetry preferences found.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(inspector.settings) { setting in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(setting.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(setting.detail)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(setting.status.label)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(statusColor(setting.status).opacity(0.15))
                            .foregroundColor(statusColor(setting.status))
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Telemetry Files")
                .font(.headline)

            if inspector.recentEvents.isEmpty {
                Text("No recent analytics, diagnostics, or crash report files found.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                List(inspector.recentEvents) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(event.path)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        HStack(spacing: 10) {
                            Text(event.date, style: .relative)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            if let size = event.size {
                                Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.inset)
                .frame(maxHeight: 320)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }

    private func statusColor(_ status: TelemetryStatus) -> Color {
        switch status {
        case .enabled: return .red
        case .disabled: return .green
        case .unknown: return .gray
        }
    }
}
