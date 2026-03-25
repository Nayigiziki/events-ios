import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @AppStorage("profileComplete") var profileComplete = false

    var body: some View {
        Group {
            if !authViewModel.isAuthenticated {
                NavigationStack {
                    LoginView()
                }
            } else if authViewModel.isFirstLaunch {
                OnboardingView()
            } else if !profileComplete {
                ProfileSetupView()
            } else {
                MainTabView()
            }
        }
        .environmentObject(authViewModel)
        .onAppear {
            authViewModel.checkSession()
        }
    }
}

#Preview {
    ContentView()
}
