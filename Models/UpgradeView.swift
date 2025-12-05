//
//  UpgradeView.swift
//  Mad Scientist
//

import SwiftUI

struct UpgradeView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var selectedPlan: SubscriptionTier = .premium
    @State private var isAnnual = true
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Upgrade to Pro")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Unlock the full power of Mad Scientist")
                        .font(.title3)
                        .foregroundColor(.secondary)
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
                .background(Color(.controlBackgroundColor))
                .cornerRadius(12)

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
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
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

                VStack(spacing: 4) {
                    Text(isAnnual ? annualPrice : monthlyPrice)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(isAnnual ? "/year" : "/month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? tierColor.opacity(0.1) : Color(.controlBackgroundColor))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? tierColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct PremiumUpgradeView: View {
    let feature: String
    @State private var showUpgradeSheet = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Premium Feature")
                .font(.title)
                .fontWeight(.bold)

            Text("\(feature) requires a premium subscription")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Upgrade Now") {
                showUpgradeSheet = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showUpgradeSheet) {
            UpgradeView()
        }
    }
}
