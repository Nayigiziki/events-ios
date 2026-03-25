import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var birthdate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var selectedGender = ""
    @State private var agreedToTerms = false

    private let genderOptions: [(key: String, value: String)] = [
        ("male", "auth_gender_male"),
        ("female", "auth_gender_female"),
        ("non-binary", "auth_gender_nonbinary"),
        ("prefer-not-to-say", "auth_gender_prefer_not")
    ]

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    // MARK: - Header

                    VStack(spacing: DNSpace.sm) {
                        ZStack {
                            RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                                .fill(Color.dnPrimary)
                                .frame(width: 56, height: 56)
                                .dnNeuRaised(intensity: .medium, cornerRadius: DNRadius.lg)

                            Image(systemName: "heart.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }

                        Text(String(localized: "auth_create_account"))
                            .dnH2()

                        Text(String(localized: "auth_create_subtitle"))
                            .dnCaption()
                    }
                    .padding(.top, DNSpace.xl)

                    // MARK: - Form

                    VStack(spacing: DNSpace.lg) {
                        // Name
                        VStack(alignment: .leading, spacing: DNSpace.sm) {
                            Text(String(localized: "auth_name"))
                                .dnSmall()
                                .textCase(.uppercase)

                            DNTextField(
                                placeholder: String(localized: "placeholder_name"),
                                text: $name,
                                icon: "person"
                            )
                        }

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

                        // Confirm Password
                        VStack(alignment: .leading, spacing: DNSpace.sm) {
                            Text(String(localized: "auth_confirm_password"))
                                .dnSmall()
                                .textCase(.uppercase)

                            DNSecureField(
                                placeholder: "••••••••",
                                text: $confirmPassword,
                                icon: "lock"
                            )
                        }

                        // Birthdate
                        VStack(alignment: .leading, spacing: DNSpace.sm) {
                            Text(String(localized: "auth_birthdate"))
                                .dnSmall()
                                .textCase(.uppercase)

                            DNCard(cornerRadius: DNRadius.md) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.dnPrimary)
                                        .font(.system(size: 16, weight: .medium))

                                    DatePicker(
                                        "",
                                        selection: $birthdate,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                }
                            }
                        }

                        // Gender
                        VStack(alignment: .leading, spacing: DNSpace.sm) {
                            Text(String(localized: "auth_gender"))
                                .dnSmall()
                                .textCase(.uppercase)

                            DNCard(cornerRadius: DNRadius.md) {
                                Picker(
                                    String(localized: "auth_gender_select"),
                                    selection: $selectedGender
                                ) {
                                    Text(String(localized: "auth_gender_select"))
                                        .tag("")

                                    ForEach(genderOptions, id: \.key) { option in
                                        Text(String(localized: String.LocalizationValue(option.value)))
                                            .tag(option.key)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.dnTextPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        // Terms
                        DNCheckbox(
                            label: String(localized: "auth_terms_agree"),
                            isOn: $agreedToTerms
                        )
                        .padding(.vertical, DNSpace.xs)

                        // Sign Up Button
                        DNButton(String(localized: "auth_sign_up"), variant: .primary) {
                            Task {
                                await authViewModel.signUp(
                                    email: email,
                                    password: password,
                                    name: name,
                                    birthdate: birthdate,
                                    gender: selectedGender.isEmpty ? nil : selectedGender
                                )
                            }
                        }
                        .opacity(agreedToTerms ? 1.0 : 0.5)
                        .allowsHitTesting(agreedToTerms)

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

                    // MARK: - Sign In Link

                    HStack(spacing: DNSpace.xs) {
                        Text(String(localized: "auth_have_account"))
                            .dnBody()

                        Button {
                            dismiss()
                        } label: {
                            Text(String(localized: "auth_sign_in"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.dnPrimary)
                        }
                    }
                    .padding(.bottom, DNSpace.xxl)
                }
                .padding(.horizontal, DNSpace.xl)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.dnTextPrimary)
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
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
