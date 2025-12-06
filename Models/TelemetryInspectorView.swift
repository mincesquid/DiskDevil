import SwiftUI

struct TelemetryInspectorView: View {
    // MARK: Internal

    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                Text("Telemetry Inspector")
                    .appFont(26, weight: .heavy)
                    .foregroundColor(.white)
                Text("Review diagnostics, analytics, and crash reporting settings")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 20)

            settingsSection
            eventsSection

            Spacer()
        }
        .padding()
        .aeroBackground()
        .onAppear {
            inspector.refresh()
        }
    }

    // MARK: Private

    @StateObject private var inspector = TelemetryService()

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .appFont(18, weight: .semibold)
                .foregroundColor(.white)

            if inspector.settings.isEmpty {
                Text("No telemetry preferences found.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            } else {
                ForEach(inspector.settings) { setting in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(setting.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text(setting.detail)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                        Text(setting.status.label)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(statusColor(setting.status).opacity(0.2))
                            .foregroundColor(statusColor(setting.status))
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Telemetry Files")
                .appFont(18, weight: .semibold)
                .foregroundColor(.white)

            if inspector.recentEvents.isEmpty {
                Text("No recent analytics, diagnostics, or crash report files found.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
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
        .glassCard()
    }

    private func statusColor(_ status: TelemetryStatus) -> Color {
        switch status {
        case .enabled: .red
        case .disabled: .green
        case .unknown: .gray
        }
    }
}
