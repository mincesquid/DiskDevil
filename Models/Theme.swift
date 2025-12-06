import SwiftUI

// MARK: - AeroTheme

enum AeroTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.16, green: 0.36, blue: 0.84),
            Color(red: 0.05, green: 0.20, blue: 0.48),
            Color(red: 0.16, green: 0.36, blue: 0.84),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surface = LinearGradient(
        colors: [
            Color.white.opacity(0.24),
            Color.white.opacity(0.08),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = Color(red: 0.36, green: 0.76, blue: 1.0)
    static let neon = Color(red: 0.21, green: 0.94, blue: 0.68)
    static let flare = Color(red: 1.0, green: 0.3, blue: 0.42)
    static let sun = Color(red: 1.0, green: 0.78, blue: 0.26)
    // Using SF Pro (macOS system font) for better compatibility
    // Fallback order: SF Pro Display -> Helvetica Neue -> System
    static let fontName = "SF Pro Display"
    static let baseFont: Font = .system(size: 15, weight: .regular, design: .default)
}

// MARK: - GlassCard

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                ZStack {
                    AeroTheme.surface
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 10)
                        .shadow(color: Color.white.opacity(0.16), radius: 6, x: -4, y: -4)
                }
            )
            .background(.ultraThinMaterial)
            .cornerRadius(16)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }

    func aeroBackground() -> some View {
        background(
            ZStack {
                AeroTheme.background
                RoundedRectangle(cornerRadius: 200)
                    .fill(AeroTheme.neon.opacity(0.12))
                    .blur(radius: 80)
                    .offset(x: -120, y: -220)
                RoundedRectangle(cornerRadius: 200)
                    .fill(AeroTheme.accent.opacity(0.18))
                    .blur(radius: 90)
                    .offset(x: 180, y: 240)
                RoundedRectangle(cornerRadius: 220)
                    .fill(AeroTheme.flare.opacity(0.14))
                    .blur(radius: 100)
                    .offset(x: 0, y: 160)
            }
        )
    }

    func appFont(_ size: CGFloat, weight: Font.Weight = .regular) -> some View {
        // Use native macOS system font with specified weight for better rendering
        font(.system(size: size, weight: weight, design: .default))
    }
}
