import SwiftUI

struct MessageBubbleView: View {
    let message: MockMessage

    var body: some View {
        HStack {
            if message.isSent {
                Spacer(minLength: UIScreen.main.bounds.width * 0.25)
            }

            VStack(alignment: message.isSent ? .trailing : .leading, spacing: DNSpace.xs) {
                Text(message.text)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(message.isSent ? .white : .dnTextPrimary)
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.md)
                    .background(
                        Group {
                            if message.isSent {
                                RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                                    .fill(Color.dnPrimary)
                                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.lg)
                            } else {
                                RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                                    .fill(Color.dnBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                                            .stroke(Color.dnShadowDark, lineWidth: 1)
                                    )
                                    .dnNeuPressed(intensity: .light, cornerRadius: DNRadius.lg)
                            }
                        }
                    )

                Text(message.timestamp)
                    .dnSmall()
                    .padding(.horizontal, DNSpace.xs)
            }

            if !message.isSent {
                Spacer(minLength: UIScreen.main.bounds.width * 0.25)
            }
        }
    }
}
