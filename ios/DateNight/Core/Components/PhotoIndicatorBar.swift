import SwiftUI

struct PhotoIndicatorBar: View {
    let count: Int
    let activeIndex: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0 ..< count, id: \.self) { index in
                Circle()
                    .fill(index == activeIndex ? Color.dnPrimary : Color.dnMuted)
                    .frame(
                        width: index == activeIndex ? 8 : 6,
                        height: index == activeIndex ? 8 : 6
                    )
                    .animation(.easeInOut(duration: 0.2), value: activeIndex)
            }
        }
    }
}
