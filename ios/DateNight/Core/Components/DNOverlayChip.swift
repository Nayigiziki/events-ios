import SwiftUI

struct DNOverlayChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .tracking(0.3)
            .foregroundColor(.dnOverlayText)
            .padding(.horizontal, DNSpace.md)
            .padding(.vertical, DNSpace.xs)
            .background(
                Capsule()
                    .fill(Color.dnOverlayChipBg)
                    .overlay(
                        Capsule()
                            .stroke(Color.dnOverlayChipStroke, lineWidth: 1)
                    )
            )
    }
}
