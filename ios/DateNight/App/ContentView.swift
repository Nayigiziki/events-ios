import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isCheckingSession {
                splashView
            } else if !authViewModel.isAuthenticated {
                NavigationStack {
                    LoginView()
                }
            } else if authViewModel.isFirstLaunch {
                OnboardingView()
            } else if !authViewModel.profileComplete {
                ProfileSetupView()
            } else {
                MainTabView()
            }
        }
        .environmentObject(authViewModel)
        .task {
            await authViewModel.checkSession()
        }
    }

    private var splashView: some View {
        ZStack {
            Color.dnBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.dnPrimary)
                ProgressView()
                    .tint(.dnPrimary)
            }
        }
    }
}

#Preview {
    ContentView()
}
