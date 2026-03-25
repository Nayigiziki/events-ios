import SwiftUI

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Color Palette

extension Color {
    static let dnBackground = Color(hex: "E0E5EC")
    static let dnShadowDark = Color(hex: "a3b1c6").opacity(0.50)
    static let dnShadowLight = Color.white.opacity(0.95)

    static let dnTextPrimary = Color(hex: "1a1a2e")
    static let dnTextSecondary = Color(hex: "4a4a6a")
    static let dnTextTertiary = Color(hex: "a4b0c0")

    static let dnPrimary = Color(hex: "6c5ce7")
    static let dnAccentPink = Color(hex: "fd79a8")
    static let dnSuccess = Color(hex: "00b894")
    static let dnInfo = Color(hex: "0984e3")
    static let dnWarning = Color(hex: "fdcb6e")
    static let dnDestructive = Color(hex: "d63031")

    static let dnBorder = Color(hex: "a4b0c0")
    static let dnMuted = Color(hex: "c8d0e0")

    // MARK: - Overlay Colors (for text/chips on dark image backgrounds)

    static let dnOverlayChipBg = Color.white.opacity(0.2)
    static let dnOverlayChipStroke = Color.white.opacity(0.3)
    static let dnOverlayText = Color.white
    static let dnOverlayTextMuted = Color.white.opacity(0.9)
}

// MARK: - Gradients

enum DNGradient {
    static let accentPill = LinearGradient(
        colors: [Color.dnAccentPink, Color.dnPrimary],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let imageOverlayBottom = LinearGradient(
        colors: [Color.black.opacity(0.7), Color.clear],
        startPoint: .bottom,
        endPoint: .top
    )
    static let imageOverlayTop = LinearGradient(
        colors: [Color.black.opacity(0.4), Color.clear],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Hero gradient from Figma: rgba(26,26,46,0.8) -> rgba(26,26,46,0.4) -> clear
    static let heroGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "1a1a2e").opacity(0.8), location: 0),
            .init(color: Color(hex: "1a1a2e").opacity(0.4), location: 0.5),
            .init(color: .clear, location: 1.0)
        ],
        startPoint: .bottom,
        endPoint: .top
    )
}

// MARK: - Spacing

enum DNSpace {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Corner Radius

enum DNRadius {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let full: CGFloat = 9999
}
