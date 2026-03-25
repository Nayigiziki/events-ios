import SwiftUI

// MARK: - Typography

extension View {
    func dnH1() -> some View {
        font(.system(size: 30, weight: .heavy))
            .tracking(-0.02 * 30)
            .foregroundColor(.dnTextPrimary)
    }

    func dnH2() -> some View {
        font(.system(size: 24, weight: .bold))
            .tracking(-0.02 * 24)
            .foregroundColor(.dnTextPrimary)
    }

    func dnH3() -> some View {
        font(.system(size: 20, weight: .bold))
            .tracking(-0.02 * 20)
            .foregroundColor(.dnTextPrimary)
    }

    func dnH4() -> some View {
        font(.system(size: 18, weight: .semibold))
            .foregroundColor(.dnTextPrimary)
    }

    func dnBody() -> some View {
        font(.system(size: 16, weight: .semibold))
            .tracking(-0.01 * 16)
            .foregroundColor(.dnTextPrimary)
    }

    func dnCaption() -> some View {
        font(.system(size: 14, weight: .semibold))
            .foregroundColor(.dnTextSecondary)
    }

    func dnSmall() -> some View {
        font(.system(size: 12, weight: .bold))
            .foregroundColor(.dnTextTertiary)
    }
}
