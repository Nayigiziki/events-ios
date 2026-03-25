import SwiftUI

// MARK: - Typography (Inter-matching with exact Figma tracking values)

extension View {
    /// H1/Title: Inter Black, 48px, uppercase by caller, tracking -0.85px, white on hero
    func dnH1() -> some View {
        font(.system(size: 48, weight: .black))
            .tracking(-0.85)
            .foregroundColor(.white)
    }

    /// H2: Inter Bold, 20px, tracking +0.05px (CTA button text)
    func dnH2() -> some View {
        font(.system(size: 20, weight: .bold))
            .tracking(0.05)
            .foregroundColor(.dnTextPrimary)
    }

    /// H3: Inter Bold, 18px, tracking -0.6px (subtitle)
    func dnH3() -> some View {
        font(.system(size: 18, weight: .bold))
            .tracking(-0.6)
            .foregroundColor(.dnTextPrimary)
    }

    /// H4: Inter SemiBold, 16px (kept for backward compat)
    func dnH4() -> some View {
        font(.system(size: 16, weight: .semibold))
            .foregroundColor(.dnTextPrimary)
    }

    /// Body/Input placeholder: Inter SemiBold, 16px, tracking -0.47px, color #4a4a6a
    func dnBody() -> some View {
        font(.system(size: 16, weight: .semibold))
            .tracking(-0.47)
            .foregroundColor(.dnTextSecondary)
    }

    /// Label: Inter Bold, 14px, uppercase by caller, tracking +0.2px, color #1a1a2e
    func dnLabel() -> some View {
        font(.system(size: 14, weight: .bold))
            .tracking(0.2)
            .foregroundColor(.dnTextPrimary)
    }

    /// Caption: Inter Bold, 14px, tracking -0.31px (same size as label, different tracking)
    func dnCaption() -> some View {
        font(.system(size: 14, weight: .bold))
            .tracking(-0.31)
            .foregroundColor(.dnTextSecondary)
    }

    /// Link text: Inter Bold, 14px, tracking -0.31px, color #6c5ce7
    func dnLink() -> some View {
        font(.system(size: 14, weight: .bold))
            .tracking(-0.31)
            .foregroundColor(.dnPrimary)
    }

    /// Small: Inter Bold, 12px
    func dnSmall() -> some View {
        font(.system(size: 12, weight: .bold))
            .foregroundColor(.dnTextTertiary)
    }
}
