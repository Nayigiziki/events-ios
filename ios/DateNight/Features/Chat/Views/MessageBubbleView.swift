import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isSent: Bool

    var body: some View {
        HStack {
            if isSent {
                Spacer(minLength: UIScreen.main.bounds.width * 0.25)
            }

            VStack(alignment: isSent ? .trailing : .leading, spacing: DNSpace.xs) {
                Text(message.content)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSent ? .white : .dnTextPrimary)
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.md)
                    .background(
                        Group {
                            if isSent {
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

                if let date = message.createdAt {
                    Text(date, style: .time)
                        .dnSmall()
                        .padding(.horizontal, DNSpace.xs)
                }
            }

            if !isSent {
                Spacer(minLength: UIScreen.main.bounds.width * 0.25)
            }
        }
    }
}
