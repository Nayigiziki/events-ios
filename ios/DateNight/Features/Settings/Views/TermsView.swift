import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DNScreen {
                ScrollView {
                    VStack(alignment: .leading, spacing: DNSpace.lg) {
                        Text("terms_of_service".localized())
                            .dnH2()

                        VStack(alignment: .leading, spacing: DNSpace.md) {
                            sectionHeader("terms_section_1")
                            sectionContent("terms_section_1_content")

                            sectionHeader("terms_section_2")
                            sectionContent("terms_section_2_content")

                            sectionHeader("terms_section_3")
                            sectionContent("terms_section_3_content")

                            sectionHeader("terms_section_4")
                            sectionContent("terms_section_4_content")

                            sectionHeader("terms_section_5")
                            sectionContent("terms_section_5_content")
                        }
                    }
                    .padding(DNSpace.lg)
                }
            }
            .navigationTitle("settings_terms".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("button_done".localized()) { dismiss() }
                }
            }
        }
    }

    private func sectionHeader(_ key: String) -> some View {
        Text(key.localized())
            .dnH3()
    }

    private func sectionContent(_ key: String) -> some View {
        Text(key.localized())
            .dnCaption()
            .foregroundColor(.dnMuted)
    }
}

#Preview {
    TermsView()
}
