import SwiftUI

struct DNStatCard: View {
    let icon: String
    let label: String
    let value: String
    var accentColor: Color = .dnPrimary

    var body: some View {
        VStack(spacing: DNSpace.sm) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(Color.dnBackground)
                    .frame(width: 40, height: 40)
                    .dnNeuPressed(intensity: .light, cornerRadius: DNRadius.full)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            // Value
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.dnTextPrimary)

            // Label
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(0.5)
                .foregroundColor(.dnTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DNSpace.md)
        .padding(.horizontal, DNSpace.sm)
        .dnNeuRaised(intensity: .light)
    }
}
