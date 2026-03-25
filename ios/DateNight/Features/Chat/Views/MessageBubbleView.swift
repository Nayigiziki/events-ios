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
                                    .shadow(
                                        color: Color(hex: "a3b1c6").opacity(0.15),
                                        radius: 8,
                                        x: 4,
                                        y: 4
                                    )
                                    .shadow(
                                        color: Color.white.opacity(0.4),
                                        radius: 8,
                                        x: -2,
                                        y: -2
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                                    .fill(Color.dnBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                                            .stroke(Color(hex: "a3b1c6").opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(
                                        color: Color(hex: "a3b1c6").opacity(0.15),
                                        radius: 4,
                                        x: 2,
                                        y: 2
                                    )
                                    .shadow(
                                        color: Color.white.opacity(0.8),
                                        radius: 4,
                                        x: -2,
                                        y: -2
                                    )
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
