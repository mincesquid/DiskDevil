//
//  UpgradeView.swift
//  DiskDevil
//

import SwiftUI

struct UpgradeView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.openWindow) private var openWindow
    @State private var selectedPlan: SubscriptionTier = .premium
    @State private var isAnnual = true
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }

                // Header
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AeroTheme.sun, AeroTheme.flare],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Upgrade to Pro")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Unlock the full power of DiskDevil")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 40)

                // Billing Toggle
                HStack {
                    Text("Monthly")
                        .foregroundColor(isAnnual ? .secondary : .primary)
                    Toggle("", isOn: $isAnnual)
                        .labelsHidden()
                        .toggleStyle(.switch)
                    Text("Annual")
                        .foregroundColor(isAnnual ? .primary : .secondary)
                    if isAnnual {
                        Text("Save 20%")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .glassCard()

                // Plan Cards
                HStack(spacing: 16) {
                    PlanCard(
                        tier: .premium,
                        monthlyPrice: "$9.99",
                        annualPrice: "$95.99",
                        isAnnual: isAnnual,
                        isSelected: selectedPlan == .premium,
                        features: [
                            "Privacy levels 1-9",
                            "Network monitoring",
                            "Recovery tools",
                            "Priority support",
                        ]
                    ) {
                        selectedPlan = .premium
                    }

                    PlanCard(
                        tier: .elite,
                        monthlyPrice: "$19.99",
                        annualPrice: "$191.99",
                        isAnnual: isAnnual,
                        isSelected: selectedPlan == .elite,
                        features: [
                            "All Premium features",
                            "Privacy level 10 (MAXIMUM)",
                            "Threat hunting",
                            "API access",
                            "Incident response",
                        ],
                        badge: "BEST VALUE"
                    ) {
                        selectedPlan = .elite
                    }
                }
                .padding(.horizontal)

                // Purchase Button
                Button(action: purchase) {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .padding(.trailing, 4)
                        }
                        Text(isPurchasing ? "Processing..." : "Subscribe to \(selectedPlan.displayName)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isPurchasing)
                .padding(.horizontal)

                // Restore Button
                Button("Restore Previous Purchase") {
                    Task {
                        await restorePurchase()
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)

                // Terms
                Text("Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .aeroBackground()
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func purchase() {
        isPurchasing = true

        Task {
            do {
                try await subscriptionManager.purchaseSubscription(tier: selectedPlan, isAnnual: isAnnual)
                await MainActor.run {
                    isPurchasing = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func restorePurchase() async {
        do {
            try await subscriptionManager.restoreSubscription()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct PlanCard: View {
    let tier: SubscriptionTier
    let monthlyPrice: String
    let annualPrice: String
    let isAnnual: Bool
    let isSelected: Bool
    let features: [String]
    var badge: String?
    let action: () -> Void

    var tierColor: Color {
        switch tier {
        case .free: return .gray
        case .premium: return .orange
        case .elite: return .purple
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                if let badge = badge {
                    Text(badge)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(tierColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Image(systemName: tier == .elite ? "crown.fill" : "star.fill")
                    .font(.title)
                    .foregroundColor(tierColor)

                Text(tier.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(spacing: 4) {
                    Text(isAnnual ? annualPrice : monthlyPrice)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(isAnnual ? "/year" : "/month")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AeroTheme.neon)
                                .font(.caption)
                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? tierColor.opacity(0.2) : Color.white.opacity(0.08))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? tierColor : Color.white.opacity(0.15), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .glassCard()
    }
}

struct PremiumUpgradeView: View {
    let feature: String
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Premium Feature")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("\(feature) requires a premium subscription")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            Button("Upgrade Now") {
                openWindow(id: "upgrade")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .padding()
    }
}
