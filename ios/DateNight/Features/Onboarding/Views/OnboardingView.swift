import SwiftUI

private struct OnboardingStep {
    let icon: String
    let titleKey: String
    let subtitleKey: String
}

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var currentStep = 0

    private let steps: [OnboardingStep] = [
        OnboardingStep(
            icon: "heart.circle.fill",
            titleKey: "onboarding_welcome_title",
            subtitleKey: "onboarding_welcome_subtitle"
        ),
        OnboardingStep(
            icon: "calendar.circle.fill",
            titleKey: "onboarding_events_title",
            subtitleKey: "onboarding_events_subtitle"
        ),
        OnboardingStep(
            icon: "sparkle.magnifyingglass",
            titleKey: "onboarding_matches_title",
            subtitleKey: "onboarding_matches_subtitle"
        ),
        OnboardingStep(
            icon: "message.circle.fill",
            titleKey: "onboarding_chat_title",
            subtitleKey: "onboarding_chat_subtitle"
        ),
        OnboardingStep(
            icon: "person.circle.fill",
            titleKey: "onboarding_profile_title",
            subtitleKey: "onboarding_profile_subtitle"
        )
    ]

    private let totalSteps = 5

    var body: some View {
        DNScreen {
            VStack(spacing: 0) {
                // Skip button (steps 1-4)
                HStack {
                    Spacer()
                    if currentStep < totalSteps - 1 {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text(String(localized: "button_skip"))
                                .dnCaption()
                                .foregroundColor(.dnPrimary)
                                .padding(.horizontal, DNSpace.lg)
                                .padding(.vertical, DNSpace.sm)
                        }
                    }
                }
                .frame(height: 44)
                .padding(.horizontal, DNSpace.md)

                // Page content
                TabView(selection: $currentStep) {
                    ForEach(0 ..< totalSteps, id: \.self) { index in
                        OnboardingStepView(
                            icon: steps[index].icon,
                            titleKey: steps[index].titleKey,
                            subtitleKey: steps[index].subtitleKey,
                            stepNumber: index + 1,
                            totalSteps: totalSteps
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.dnCardEntry, value: currentStep)

                // Bottom section
                VStack(spacing: DNSpace.lg) {
                    // Page indicator
                    PageIndicatorBar(
                        currentStep: currentStep,
                        totalSteps: totalSteps
                    )

                    // Action button
                    if currentStep < totalSteps - 1 {
                        DNButton(String(localized: "button_next"), variant: .secondary) {
                            withAnimation(.dnCardEntry) {
                                currentStep += 1
                            }
                        }
                    } else {
                        DNButton(String(localized: "onboarding_get_started"), variant: .primary) {
                            completeOnboarding()
                        }
                    }
                }
                .padding(.horizontal, DNSpace.xl)
                .padding(.bottom, DNSpace.xxl)
            }
        }
    }

    private func completeOnboarding() {
        authViewModel.completeOnboarding()
    }
}

// MARK: - Step View

private struct OnboardingStepView: View {
    let icon: String
    let titleKey: String
    let subtitleKey: String
    let stepNumber: Int
    let totalSteps: Int

    var body: some View {
        VStack(spacing: DNSpace.xl) {
            Spacer()

            DNCard {
                VStack(spacing: DNSpace.xl) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.dnPrimary.opacity(0.12))
                            .frame(width: 100, height: 100)

                        Image(systemName: icon)
                            .font(.system(size: 48))
                            .foregroundColor(.dnPrimary)
                    }

                    // Step badge
                    Text(String(localized: "onboarding_step", defaultValue: "Step \(stepNumber) of \(totalSteps)"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, DNSpace.md)
                        .padding(.vertical, DNSpace.xs)
                        .background(
                            Capsule()
                                .fill(Color.dnPrimary)
                        )

                    // Title
                    Text(String(localized: String.LocalizationValue(titleKey)))
                        .dnH2()
                        .multilineTextAlignment(.center)

                    // Subtitle
                    Text(String(localized: String.LocalizationValue(subtitleKey)))
                        .dnBody()
                        .foregroundColor(.dnTextSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .padding(.horizontal, DNSpace.xl)
    }
}

// MARK: - Page Indicator Bar

struct PageIndicatorBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: DNSpace.sm) {
            ForEach(0 ..< totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? Color.dnPrimary : Color.dnMuted)
                    .frame(height: 6)
                    .frame(maxWidth: index == currentStep ? 32 : 12)
                    .animation(.dnButtonPress, value: currentStep)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthViewModel())
}
