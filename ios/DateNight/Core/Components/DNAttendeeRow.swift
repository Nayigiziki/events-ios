import SwiftUI

struct DNAttendeeRow: View {
    let attendees: [UserProfile]
    var maxVisible: Int = 5
    var avatarSize: CGFloat = 48
    var showNames: Bool = true
    var label: String = "Asistiendo"

    var body: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 12, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundColor(.dnTextSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DNSpace.md) {
                    ForEach(attendees.prefix(maxVisible)) { user in
                        VStack(spacing: DNSpace.xs) {
                            AvatarView(
                                url: URL(string: user.avatarUrl ?? ""),
                                size: avatarSize
                            )
                            if showNames {
                                Text(user.name.components(separatedBy: " ").first ?? user.name)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.dnTextPrimary)
                            }
                        }
                    }
                    if attendees.count > maxVisible {
                        VStack(spacing: DNSpace.xs) {
                            ZStack {
                                Circle()
                                    .fill(Color.dnBackground)
                                    .frame(width: avatarSize, height: avatarSize)
                                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                                Text("+\(attendees.count - maxVisible)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.dnPrimary)
                            }
                            if showNames {
                                Text("More")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.dnTextPrimary)
                            }
                        }
                    }
                }
            }
        }
    }
}
