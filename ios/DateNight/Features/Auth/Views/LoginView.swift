import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xxl) {
                    // MARK: - Hero / Logo

                    heroSection
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.top, DNSpace.xxl)

                    // MARK: - Form

                    VStack(spacing: DNSpace.lg) {
                        // Email
                        VStack(alignment: .leading, spacing: DNSpace.sm) {
                            Text(String(localized: "auth_email"))
                                .dnLabel()
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
                                .dnLabel()
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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.dnTextSecondary)

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

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack {
            // Background image
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
            .frame(height: 341)
            .clipped()

            // Gradient overlay: rgba(26,26,46,0.8) at bottom -> 0.4 at 50% -> clear at top
            DNGradient.heroGradient

            // Content overlay
            VStack(spacing: DNSpace.sm) {
                // Heart icon in purple rounded square
                Image(systemName: "heart.fill")
                    .font(.system(size: 48, weight: .regular))
                    .foregroundColor(.white)
                    .frame(width: 96, height: 96)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.dnPrimary)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 8, y: 8)
                    .shadow(color: Color.white.opacity(0.1), radius: 4, x: -2, y: -2)

                // Title
                Text("DATENIGHT")
                    .font(.system(size: 48, weight: .black))
                    .tracking(-0.85)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 12, x: 0, y: 4)

                // Subtitle
                Text(String(localized: "auth_app_tagline"))
                    .font(.system(size: 18, weight: .bold))
                    .tracking(-0.6)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 244)
            }
        }
        .frame(height: 341)
        .clipShape(RoundedRectangle(cornerRadius: DNRadius.xxl, style: .continuous))
        .shadow(
            color: Color(hex: "a3b1c6"),
            radius: 24,
            x: 12,
            y: 12
        )
        .shadow(
            color: Color.white,
            radius: 24,
            x: -12,
            y: -12
        )
    }
}

// MARK: - Secure Field Component

struct DNSecureField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 0) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? .dnPrimary : .dnTextTertiary)
                    .font(.system(size: 24, weight: .medium))
                    .frame(width: 24, height: 24)
                    .padding(.leading, 20)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            }

            SecureField(placeholder, text: $text)
                .font(.system(size: 16, weight: .semibold))
                .tracking(-0.47)
                .foregroundColor(.dnTextPrimary)
                .focused($isFocused)
                .padding(.leading, icon != nil ? 12 : 56)
                .padding(.trailing, 20)
        }
        .padding(.vertical, 20)
        .frame(height: 64)
        .dnNeuPressed(intensity: .medium, cornerRadius: DNRadius.md)
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
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.dnBackground)
                        .frame(width: 24, height: 24)
                        .dnNeuPressed(intensity: .light, cornerRadius: 24)

                    if isOn {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.dnPrimary)
                            .frame(width: 16, height: 16)
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
