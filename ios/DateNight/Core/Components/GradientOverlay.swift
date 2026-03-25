import SwiftUI

struct GradientOverlay: View {
    var opacity: Double = 0.6
    var alignment: Alignment = .bottom

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .clear,
                Color.black.opacity(opacity)
            ]),
            startPoint: alignment == .bottom ? .top : .bottom,
            endPoint: alignment == .bottom ? .bottom : .top
        )
    }
}
