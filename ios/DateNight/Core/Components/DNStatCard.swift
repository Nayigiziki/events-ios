import SwiftUI

struct DNStatCard: View {
    let icon: String
    let label: String
    let value: String
    var accentColor: Color = .dnPrimary

    var body: some View {
        HStack(spacing: DNSpace.md) {
            ZStack {
                Circle()
                    .fill(Color.dnBackground)
                    .frame(width: 48, height: 48)
                    .dnNeuPressed(cornerRadius: DNRadius.full)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text(label)
                    .dnCaption()

                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
            }
        }
        .padding(DNSpace.md)
        .dnNeuRaised()
    }
}
