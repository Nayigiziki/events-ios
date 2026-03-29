import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DNScreen {
                ScrollView {
                    VStack(alignment: .leading, spacing: DNSpace.lg) {
                        Text("privacy_policy".localized())
                            .dnH2()

                        VStack(alignment: .leading, spacing: DNSpace.md) {
                            sectionHeader("privacy_section_1")
                            sectionContent("privacy_section_1_content")

                            sectionHeader("privacy_section_2")
                            sectionContent("privacy_section_2_content")

                            sectionHeader("privacy_section_3")
                            sectionContent("privacy_section_3_content")

                            sectionHeader("privacy_section_4")
                            sectionContent("privacy_section_4_content")

                            sectionHeader("privacy_section_5")
                            sectionContent("privacy_section_5_content")
                        }
                    }
                    .padding(DNSpace.lg)
                }
            }
            .navigationTitle("settings_privacy_policy".localized())
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
    PrivacyPolicyView()
}
