import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showDeleteConfirmation = false

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    Text("SETTINGS")
                        .dnH2()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Account
                    sectionHeader("ACCOUNT")
                    DNCard {
                        VStack(spacing: 0) {
                            settingsRow(icon: "person.circle", title: "Edit Profile", showChevron: true)
                            divider
                            settingsRow(icon: "lock", title: "Change Password", showChevron: true)
                            divider
                            settingsRow(icon: "envelope", title: "Email", showChevron: true)
                        }
                    }

                    // Notifications
                    sectionHeader("NOTIFICATIONS")
                    DNCard {
                        VStack(spacing: 0) {
                            toggleRow(title: "Matches", isOn: $viewModel.notifyMatches)
                            divider
                            toggleRow(title: "Messages", isOn: $viewModel.notifyMessages)
                            divider
                            toggleRow(title: "Events", isOn: $viewModel.notifyEvents)
                            divider
                            toggleRow(title: "Date Reminders", isOn: $viewModel.notifyDateReminders)
                            divider
                            toggleRow(title: "Friend Requests", isOn: $viewModel.notifyFriendRequests)
                        }
                    }

                    // Privacy
                    sectionHeader("PRIVACY")
                    DNCard {
                        VStack(spacing: 0) {
                            toggleRow(title: "Show Profile", isOn: $viewModel.showProfile)
                            divider
                            toggleRow(title: "Show Distance", isOn: $viewModel.showDistance)
                            divider
                            toggleRow(title: "Show Online Status", isOn: $viewModel.showOnlineStatus)
                        }
                    }

                    // Preferences
                    sectionHeader("PREFERENCES")
                    DNCard {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Language")
                                    .dnBody()
                                Spacer()
                                Picker("Language", selection: $viewModel.selectedLanguage) {
                                    ForEach(viewModel.languages, id: \.self) { lang in
                                        Text(lang).tag(lang)
                                    }
                                }
                                .tint(.dnPrimary)
                            }
                            divider
                            toggleRow(title: "Dark Mode", isOn: $viewModel.darkModeEnabled)
                        }
                    }

                    // Support
                    sectionHeader("SUPPORT")
                    DNCard {
                        VStack(spacing: 0) {
                            settingsRow(icon: "questionmark.circle", title: "Help Center", showChevron: true)
                            divider
                            settingsRow(icon: "exclamationmark.bubble", title: "Report a Problem", showChevron: true)
                            divider
                            settingsRow(icon: "doc.text", title: "Terms of Service", showChevron: true)
                            divider
                            settingsRow(icon: "hand.raised", title: "Privacy Policy", showChevron: true)
                        }
                    }

                    // Danger Zone
                    sectionHeader("DANGER ZONE")
                    DNCard {
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.dnDestructive)
                                Text("Delete Account")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.dnDestructive)
                                Spacer()
                            }
                        }
                    }

                    // Log Out
                    DNButton("Log Out", variant: .secondary) {
                        authViewModel.signOut()
                    }

                    Spacer().frame(height: DNSpace.xxl)
                }
                .padding(DNSpace.lg)
            }
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
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
