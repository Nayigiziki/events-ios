import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    // MARK: - Hero / Logo

                    AsyncImage(
                        url: URL(
                            string: "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=400&fit=crop"
                        )
                    ) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.dnMuted
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: DNRadius.xl, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DNRadius.xl, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.5), Color.clear],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                    )
                    .overlay(
                        VStack(spacing: DNSpace.sm) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .padding(DNSpace.md)
                                .background(
                                    RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                                        .fill(Color.dnPrimary)
                                )
                            Text("DATENIGHT")
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundColor(.white)
                                .tracking(2)
                            Text(String(localized: "auth_app_tagline"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    )
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.top, DNSpace.xxl)

                    // MARK: - Form

                    VStack(spacing: DNSpace.lg) {
                        // Email
                        VStack(alignment: .leading, spacing: DNSpace.sm) {
                            Text(String(localized: "auth_email"))
                                .dnSmall()
                                .textCase(.uppercase)

                            DNTextField(
                                placeholder: "email@example.com",
                                text: $email,
                                icon: "envelope"
                            )
                        }

                        // Password
                        VStack(alignment: .leading, spacing: DNSpace.sm) {
                            Text(String(localized: "auth_password"))
                                .dnSmall()
                                .textCase(.uppercase)

                            DNSecureField(
                                placeholder: "••••••••",
                                text: $password,
                                icon: "lock"
                            )
                        }

                        // Remember Me + Forgot Password
                        HStack {
                            DNCheckbox(
                                label: String(localized: "auth_remember_me"),
                                isOn: $rememberMe
                            )

                            Spacer()

                            Button {
                                // Forgot password action
                            } label: {
                                Text(String(localized: "auth_forgot_password"))
                                    .dnCaption()
                                    .foregroundColor(.dnPrimary)
                            }
                        }

                        // Sign In Button
                        DNButton(String(localized: "auth_sign_in"), variant: .primary) {
                            Task {
                                await authViewModel.signIn(email: email, password: password)
                            }
                        }
                        .padding(.top, DNSpace.sm)

                        // Error
                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .dnCaption()
                                .foregroundColor(.dnDestructive)
                                .multilineTextAlignment(.center)
                        }
                    }

                    // MARK: - Divider

                    HStack {
                        Rectangle()
                            .fill(Color.dnBorder)
                            .frame(height: 1)
                        Text(String(localized: "auth_or_continue_with"))
                            .dnSmall()
                            .textCase(.uppercase)
                            .layoutPriority(1)
                        Rectangle()
                            .fill(Color.dnBorder)
                            .frame(height: 1)
                    }

                    // MARK: - OAuth Buttons

                    HStack(spacing: DNSpace.md) {
                        DNButton(String(localized: "auth_google"), variant: .secondary) {
                            Task { await authViewModel.signInWithGoogle() }
                        }

                        DNButton(String(localized: "auth_facebook"), variant: .secondary) {
                            Task { await authViewModel.signInWithFacebook() }
                        }
                    }

                    // MARK: - Sign Up Link

                    HStack(spacing: DNSpace.xs) {
                        Text(String(localized: "auth_no_account"))
                            .dnBody()

                        NavigationLink {
                            SignUpView()
                        } label: {
                            Text(String(localized: "auth_sign_up"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.dnPrimary)
                        }
                    }
                    .padding(.bottom, DNSpace.xxl)
                }
                .padding(.horizontal, DNSpace.xl)
            }
        }
        .overlay {
            if authViewModel.isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.dnPrimary)
                    .scaleEffect(1.5)
            }
        }
    }
}

// MARK: - Secure Field Component

struct DNSecureField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: DNSpace.sm) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? .dnPrimary : .dnTextTertiary)
                    .font(.system(size: 16, weight: .medium))
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            }

            SecureField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.dnTextPrimary)
                .focused($isFocused)
        }
        .padding(.horizontal, DNSpace.lg)
        .frame(minHeight: 44)
        .dnNeuPressed(cornerRadius: DNRadius.md)
    }
}

// MARK: - Checkbox Toggle Style

struct DNCheckbox: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: DNSpace.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: DNRadius.xs, style: .continuous)
                        .fill(Color.dnBackground)
                        .frame(width: 22, height: 22)

                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.dnPrimary)
                    }
                }

                Text(label)
                    .dnCaption()
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
