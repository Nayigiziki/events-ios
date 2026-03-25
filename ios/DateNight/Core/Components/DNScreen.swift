import SwiftUI

struct DNScreen<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.dnBackground.ignoresSafeArea()
            content
        }
    }
}
