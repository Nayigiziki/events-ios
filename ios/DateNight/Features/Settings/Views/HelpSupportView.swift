import SwiftUI

struct HelpSupportView: View {
    @State private var showReportSheet = false
    @State private var reportDescription = ""

    private let faqs: [(question: String, answer: String)] = [
        (
            "How do I create a date?",
            "Browse events or matches, then tap 'Invite to Date' on any profile or event. Choose a time, add a message, and send the invitation. Your match will receive a notification to accept or decline."
        ),
        (
            "How does matching work?",
            "We match you based on shared event interests and preferences. Swipe right on profiles you like. When both people swipe right, it's a match! You can then chat and plan dates together."
        ),
        (
            "How do I add friends?",
            "Go to the Friends tab and tap the '+' button. You can search for people by name or invite friends using their email address. Friends can see your events and join group dates."
        ),
        (
            "How do I report someone?",
            "Open the user's profile and tap the '...' menu in the top-right corner. Select 'Report User' and choose a reason. Our safety team reviews all reports within 24 hours."
        ),
        (
            "How do I delete my account?",
            "Go to Settings > Danger Zone > Delete Account. This will permanently remove your profile, matches, messages, and all associated data. This action cannot be undone."
        )
    ]

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    Text("HELP & SUPPORT")
                        .dnH2()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // FAQ Section
                    Text("FAQ")
                        .dnLabel()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    DNCard {
                        VStack(spacing: DNSpace.sm) {
                            ForEach(Array(faqs.enumerated()), id: \.offset) { _, faq in
                                DisclosureGroup {
                                    Text(faq.answer)
                                        .dnBody()
                                        .padding(.top, DNSpace.sm)
                                } label: {
                                    Text(faq.question)
                                        .dnH3()
                                        .multilineTextAlignment(.leading)
                                }
                                .tint(.dnPrimary)
                            }
                        }
                    }

                    // Contact Us
                    Text("CONTACT US")
                        .dnLabel()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    DNCard {
                        HStack(spacing: DNSpace.md) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.dnPrimary)

                            Text("support@datenight.app")
                                .dnBody()

                            Spacer()
                        }
                    }

                    // Report a Problem
                    DNButton("Report a Problem", variant: .secondary) {
                        showReportSheet = true
                    }

                    // App version
                    Text("DateNight v1.0")
                        .dnSmall()
                        .padding(.top, DNSpace.lg)

                    Spacer().frame(height: DNSpace.xxl)
                }
                .padding(DNSpace.lg)
            }
        }
        .sheet(isPresented: $showReportSheet) {
            reportProblemSheet
        }
    }

    private var reportProblemSheet: some View {
        DNScreen {
            VStack(spacing: DNSpace.xl) {
                Text("REPORT A PROBLEM")
                    .dnH2()
                    .padding(.top, DNSpace.xl)

                TextEditor(text: $reportDescription)
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(-0.47)
                    .foregroundColor(.dnTextPrimary)
                    .frame(height: 150)
                    .padding(DNSpace.md)
                    .scrollContentBackground(.hidden)
                    .background(Color.dnBackground)
                    .dnNeuPressed(intensity: .medium, cornerRadius: DNRadius.md)
                    .overlay(alignment: .topLeading) {
                        if reportDescription.isEmpty {
                            Text("Describe the problem...")
                                .font(.system(size: 16, weight: .semibold))
                                .tracking(-0.47)
                                .foregroundColor(.dnTextTertiary)
                                .padding(.horizontal, DNSpace.lg)
                                .padding(.top, DNSpace.lg)
                                .allowsHitTesting(false)
                        }
                    }

                DNButton("Submit", variant: .primary) {
                    showReportSheet = false
                    reportDescription = ""
                }

                Spacer()
            }
            .padding(DNSpace.lg)
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    HelpSupportView()
}
