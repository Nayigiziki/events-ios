import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showDeleteConfirmation = false

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    Text("settings_title".localized().uppercased())
                        .dnH2()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Account
                    sectionHeader("settings_account".localized().uppercased())
                    DNCard {
                        VStack(spacing: 0) {
                            settingsRow(
                                icon: "person.circle",
                                title: "settings_edit_profile".localized(),
                                showChevron: true
                            )
                            divider
                            settingsRow(icon: "lock", title: "settings_change_password".localized(), showChevron: true)
                            divider
                            settingsRow(icon: "envelope", title: "settings_email".localized(), showChevron: true)
                        }
                    }

                    // Notifications
                    sectionHeader("settings_notifications".localized().uppercased())
                    DNCard {
                        VStack(spacing: 0) {
                            toggleRow(title: "settings_matches".localized(), isOn: $viewModel.notifyMatches)
                            divider
                            toggleRow(title: "settings_messages".localized(), isOn: $viewModel.notifyMessages)
                            divider
                            toggleRow(title: "settings_events".localized(), isOn: $viewModel.notifyEvents)
                            divider
                            toggleRow(
                                title: "settings_date_reminders".localized(),
                                isOn: $viewModel.notifyDateReminders
                            )
                            divider
                            toggleRow(
                                title: "settings_friend_requests".localized(),
                                isOn: $viewModel.notifyFriendRequests
                            )
                        }
                    }

                    // Privacy
                    sectionHeader("settings_privacy".localized().uppercased())
                    DNCard {
                        VStack(spacing: 0) {
                            toggleRow(title: "settings_show_profile".localized(), isOn: $viewModel.showProfile)
                            divider
                            toggleRow(title: "settings_show_distance".localized(), isOn: $viewModel.showDistance)
                            divider
                            toggleRow(title: "settings_show_online".localized(), isOn: $viewModel.showOnlineStatus)
                        }
                    }

                    // Preferences
                    sectionHeader("settings_preferences".localized().uppercased())
                    DNCard {
                        VStack(spacing: 0) {
                            HStack {
                                Text("settings_language".localized())
                                    .dnBody()
                                Spacer()
                                Picker("settings_language".localized(), selection: $viewModel.selectedLanguage) {
                                    ForEach(viewModel.languages, id: \.self) { lang in
                                        Text(lang).tag(lang)
                                    }
                                }
                                .tint(.dnPrimary)
                            }
                            divider
                            toggleRow(title: "settings_dark_mode".localized(), isOn: $viewModel.darkModeEnabled)
                        }
                    }

                    // Support
                    sectionHeader("settings_support".localized().uppercased())
                    DNCard {
                        VStack(spacing: 0) {
                            settingsRow(
                                icon: "questionmark.circle",
                                title: "settings_help_center".localized(),
                                showChevron: true
                            )
                            divider
                            settingsRow(
                                icon: "exclamationmark.bubble",
                                title: "settings_report_problem".localized(),
                                showChevron: true
                            )
                            divider
                            settingsRow(icon: "doc.text", title: "settings_terms".localized(), showChevron: true)
                            divider
                            settingsRow(
                                icon: "hand.raised",
                                title: "settings_privacy_policy".localized(),
                                showChevron: true
                            )
                        }
                    }

                    // Danger Zone
                    sectionHeader("settings_danger_zone".localized().uppercased())
                    DNCard {
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.dnDestructive)
                                Text("settings_delete_account".localized())
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.dnDestructive)
                                Spacer()
                            }
                        }
                    }

                    // Log Out
                    DNButton("settings_log_out".localized(), variant: .secondary) {
                        Task { await authViewModel.signOut() }
                    }

                    Spacer().frame(height: DNSpace.xxl)
                }
                .padding(DNSpace.lg)
            }
        }
        .alert("settings_delete_confirm_title".localized(), isPresented: $showDeleteConfirmation) {
            Button("button_cancel".localized(), role: .cancel) {}
            Button("button_delete".localized(), role: .destructive) {
                viewModel.deleteAccount()
            }
        } message: {
            Text("settings_delete_confirm_message".localized())
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .dnLabel()
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func settingsRow(icon: String, title: String, showChevron: Bool = false) -> some View {
        HStack(spacing: DNSpace.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.dnPrimary)
                .frame(width: 24)

            Text(title)
                .dnBody()

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.dnMuted)
            }
        }
        .padding(.vertical, DNSpace.sm)
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .dnBody()
            Spacer()
            Toggle("", isOn: isOn)
                .tint(.dnPrimary)
                .labelsHidden()
        }
        .padding(.vertical, DNSpace.xs)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.dnMuted.opacity(0.3))
            .frame(height: 1)
            .padding(.vertical, DNSpace.xs)
    }
}

#Preview {
    SettingsView()
}
