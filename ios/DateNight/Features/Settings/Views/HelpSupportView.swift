import SwiftUI

struct HelpSupportView: View {
    @State private var showReportSheet = false
    @State private var reportDescription = ""

    private var faqs: [(question: String, answer: String)] {
        [
            ("help_faq_create_date_q".localized(), "help_faq_create_date_a".localized()),
            ("help_faq_matching_q".localized(), "help_faq_matching_a".localized()),
            ("help_faq_friends_q".localized(), "help_faq_friends_a".localized()),
            ("help_faq_report_q".localized(), "help_faq_report_a".localized()),
            ("help_faq_delete_q".localized(), "help_faq_delete_a".localized())
        ]
    }

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    Text("help_title".localized().uppercased())
                        .dnH2()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // FAQ Section
                    Text("help_faq".localized().uppercased())
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
                    Text("help_contact_us".localized())
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
                    DNButton("help_report".localized(), variant: .secondary) {
                        showReportSheet = true
                    }

                    // App version
                    Text(String(format: "help_version".localized(), "1.1.0"))
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
                Text("help_report_title".localized().uppercased())
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
                            Text("help_report_placeholder".localized())
                                .font(.system(size: 16, weight: .semibold))
                                .tracking(-0.47)
                                .foregroundColor(.dnTextTertiary)
                                .padding(.horizontal, DNSpace.lg)
                                .padding(.top, DNSpace.lg)
                                .allowsHitTesting(false)
                        }
                    }

                DNButton("help_report_submit".localized(), variant: .primary) {
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
