import SwiftUI

struct ContentView: View {
    @EnvironmentObject var claudeService: ClaudeService

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("DateNight")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Powered by Claude AI")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if claudeService.isConfigured {
                    Label("Claude configured", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Label("Add API key in Settings", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }

                Spacer()

                NavigationLink("Try Example Chat") {
                    ChatView()
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("Settings") {
                    SettingsView()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ClaudeService())
}
