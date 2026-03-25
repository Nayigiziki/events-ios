import SwiftUI

struct DNCard<Content: View>: View {
    let cornerRadius: CGFloat
    let content: Content

    init(
        cornerRadius: CGFloat = DNRadius.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(DNSpace.md)
            .dnNeuRaised(cornerRadius: cornerRadius)
    }
}
