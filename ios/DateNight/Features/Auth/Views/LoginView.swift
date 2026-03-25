import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false

    var body: some View {
        ZStack {
            Color.dnBackground.ignoresSafeArea()

            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DNSpace.xl) {
                        heroSection

                        formSection

                        divider

                        oauthButtons

                        signUpLink
                    }
                    .frame(width: geo.size.width - DNSpace.xl * 2)
                    .padding(.horizontal, DNSpace.xl)
                    .padding(.top, DNSpace.lg)
                    .padding(.bottom, DNSpace.xxl)
                }
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
            .frame(height: 260)
            .clipped()

            // Gradient overlay
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "1a1a2e").opacity(0.85), location: 0),
                    .init(color: Color(hex: "1a1a2e").opacity(0.4), location: 0.5),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .bottom,
                endPoint: .top
            )

            // Content
            VStack(spacing: DNSpace.sm) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                            .fill(Color.dnPrimary)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 4, y: 4)

                Text("DATENIGHT")
                    .font(.system(size: 36, weight: .black))
                    .tracking(-0.85)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)

                Text(String(localized: "auth_app_tagline"))
                    .font(.system(size: 14, weight: .bold))
                    .tracking(-0.3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 220)
            }
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: DNRadius.xxl, style: .continuous))
        .dnNeuRaised(intensity: .extraHeavy, cornerRadius: DNRadius.xxl)
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: DNSpace.lg) {
            // Email
            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text(String(localized: "auth_email"))
                    .dnLabel()
                    .textCase(.uppercase)

                DNTextField(
                    placeholder: "tu@email.com",
                    text: $email,
                    icon: "envelope"
                )
            }

            // Password
            VStack(alignment: .leading, spacing: DNSpace.xs) {
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

                NavigationLink {
                    ForgotPasswordView()
                } label: {
                    Text(String(localized: "auth_forgot_password"))
                        .dnLink()
                }
            }

            // Sign In Button
            DNButton(String(localized: "auth_sign_in"), variant: .primary) {
                Task {
                    await authViewModel.signIn(email: email, password: password)
                }
            }

            // Error
            if let error = authViewModel.errorMessage {
                Text(error)
                    .dnCaption()
                    .foregroundColor(.dnDestructive)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Divider

    private var divider: some View {
        HStack(spacing: DNSpace.md) {
            Rectangle()
                .fill(Color.dnBorder)
                .frame(height: 1)
            Text(String(localized: "auth_or_continue_with"))
                .font(.system(size: 12, weight: .bold))
                .tracking(0.2)
                .foregroundColor(.dnTextSecondary)
                .textCase(.uppercase)
                .fixedSize()
            Rectangle()
                .fill(Color.dnBorder)
                .frame(height: 1)
        }
    }

    // MARK: - OAuth

    private var oauthButtons: some View {
        HStack(spacing: DNSpace.md) {
            Button {
                Task { await authViewModel.signInWithGoogle() }
            } label: {
                Text("Google")
                    .font(.system(size: 16, weight: .bold))
                    .tracking(-0.47)
                    .foregroundColor(.dnTextPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.plain)
            .dnNeuRaised(intensity: .medium, cornerRadius: DNRadius.md)

            Button {
                Task { await authViewModel.signInWithFacebook() }
            } label: {
                Text("Facebook")
                    .font(.system(size: 16, weight: .bold))
                    .tracking(-0.47)
                    .foregroundColor(.dnTextPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.plain)
            .dnNeuRaised(intensity: .medium, cornerRadius: DNRadius.md)
        }
    }

    // MARK: - Sign Up

    private var signUpLink: some View {
        HStack(spacing: DNSpace.xs) {
            Text(String(localized: "auth_no_account"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.dnTextPrimary)

            NavigationLink {
                SignUpView()
            } label: {
                Text(String(localized: "auth_sign_up"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.dnPrimary)
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
        HStack(spacing: DNSpace.md) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? .dnPrimary : .dnTextTertiary)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 24, height: 24)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            }

            SecureField(placeholder, text: $text)
                .font(.system(size: 16, weight: .semibold))
                .tracking(-0.47)
                .foregroundColor(.dnTextPrimary)
                .focused($isFocused)
        }
        .padding(.horizontal, DNSpace.lg)
        .frame(height: 64)
        .dnNeuPressed(intensity: .medium, cornerRadius: DNRadius.md)
    }
}

// MARK: - Checkbox

struct DNCheckbox: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: DNSpace.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: DNRadius.sm, style: .continuous)
                        .fill(Color.dnBackground)
                        .frame(width: 24, height: 24)
                        .dnNeuPressed(intensity: .light, cornerRadius: DNRadius.sm)

                    if isOn {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.dnPrimary)
                            .frame(width: 16, height: 16)
                    }
                }

                Text(label)
                    .font(.system(size: 14, weight: .bold))
                    .tracking(-0.31)
                    .foregroundColor(.dnTextPrimary)
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
