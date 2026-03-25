import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var claudeService: ClaudeService

    var body: some View {
        Form {
            Section("Claude AI Configuration") {
                if Configuration.isAIProxyConfigured {
                    Label {
                        VStack(alignment: .leading) {
                            Text("AIProxy")
                            Text("Configured for production")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                    }
                } else if Configuration.isDirectAPIConfigured {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Direct API Key")
                            Text("Development mode")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.orange)
                    }
                } else {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Not Configured")
                                .foregroundStyle(.primary)
                            Text("Add your API key to Secrets.xcconfig")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }

                Link(destination: URL(string: "https://console.anthropic.com/settings/keys")!) {
                    Label("Get API Key", systemImage: "key")
                }
            }

            Section("Logging") {
                Button {
                    Logger.clearLogs()
                } label: {
                    Label("Clear Logs", systemImage: "trash")
                }

                if let logPath = URL(string: "file://\(Logger.logFilePath)") {
                    ShareLink(item: logPath) {
                        Label("Share Logs", systemImage: "square.and.arrow.up")
                    }
                }
            }

            Section("About") {
                LabeledContent("Version", value: appVersion)
                LabeledContent("Build", value: buildNumber)
            }

            Section {
                VStack(alignment: .center, spacing: 8) {
                    Text("DateNight")
                        .font(.headline)
                    Text("Built with Claude AI")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Settings")
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(ClaudeService())
    }
}
