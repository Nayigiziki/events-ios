import SwiftUI

struct HelpCenterView: View {
    @Environment(\.dismiss) private var dismiss

    let faqItems = [
        ("faq_getting_started", "faq_getting_started_answer"),
        ("faq_profile", "faq_profile_answer"),
        ("faq_matches", "faq_matches_answer"),
        ("faq_messages", "faq_messages_answer"),
        ("faq_safety", "faq_safety_answer")
    ]

    var body: some View {
        NavigationStack {
            DNScreen {
                ScrollView {
                    VStack(spacing: DNSpace.lg) {
                        ForEach(0 ..< faqItems.count, id: \.self) { index in
                            VStack(alignment: .leading, spacing: DNSpace.sm) {
                                Text(faqItems[index].0.localized())
                                    .dnH3()
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(faqItems[index].1.localized())
                                    .dnCaption()
                                    .foregroundColor(.dnMuted)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(DNSpace.md)
                            .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.md)
                        }

                        VStack(spacing: DNSpace.md) {
                            Text("settings_cant_find_answer".localized())
                                .dnBody()
                                .foregroundColor(.dnMuted)

                            DNButton("settings_contact_support".localized(), variant: .primary) {
                                // Open support email
                                if let url = URL(string: "mailto:support@datenight.app") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        .padding(DNSpace.md)
                    }
                    .padding(DNSpace.lg)
                }
            }
            .navigationTitle("settings_help_center".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("button_done".localized()) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    HelpCenterView()
}
