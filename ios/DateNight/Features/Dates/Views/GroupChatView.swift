import SwiftUI

struct GroupChatView: View {
    let groupName: String

    var body: some View {
        DNScreen {
            VStack(spacing: DNSpace.xl) {
                Text(groupName)
                    .dnH2()

                Text("Group chat coming soon")
                    .dnBody()

                Spacer()
            }
            .padding(.top, DNSpace.xxl)
        }
    }
}
