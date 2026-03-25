import SwiftUI

struct ProfileSetupView: View {
    @StateObject private var viewModel = ProfileSetupViewModel()
    @AppStorage("profileComplete") private var profileComplete = false

    var body: some View {
        DNScreen {
            VStack(spacing: DNSpace.xl) {
                // MARK: - Progress Indicator

                progressDots
                    .padding(.top, DNSpace.lg)

                // MARK: - Step Content

                ScrollView {
                    VStack(spacing: DNSpace.xxl) {
                        switch viewModel.currentStep {
                        case 0:
                            photosStep
                        case 1:
                            aboutStep
                        case 2:
                            interestsStep
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, DNSpace.xl)
                    .padding(.bottom, DNSpace.xxl)
                }

                // MARK: - Navigation Buttons

                navigationButtons
                    .padding(.horizontal, DNSpace.xl)
                    .padding(.bottom, DNSpace.lg)
            }
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.dnPrimary)
                    .scaleEffect(1.5)
            }
        }
        .onChange(of: profileComplete) { _, newValue in
            // This triggers ContentView to re-evaluate auth gate
            if newValue {
                // Profile complete flag is already persisted via @AppStorage
            }
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: DNSpace.md) {
            ForEach(0 ..< ProfileSetupViewModel.totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= viewModel.currentStep ? Color.dnPrimary : Color.dnMuted)
                    .frame(
                        width: step == viewModel.currentStep ? 12 : 8,
                        height: step == viewModel.currentStep ? 12 : 8
                    )
                    .animation(.easeInOut(duration: 0.2), value: viewModel.currentStep)
            }
        }
    }

    // MARK: - Step 1: Photos

    private var photosStep: some View {
        VStack(spacing: DNSpace.xl) {
            Text("Add Your Photos")
                .dnH2()

            Text("Add at least 2 photos to continue")
                .dnBody()

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: DNSpace.md), count: 3),
                spacing: DNSpace.md
            ) {
                ForEach(0 ..< ProfileSetupViewModel.maxPhotos, id: \.self) { index in
                    if index < viewModel.photos.count {
                        // Filled photo slot
                        filledPhotoSlot(at: index)
                    } else {
                        // Empty photo slot
                        emptyPhotoSlot
                    }
                }
            }
        }
    }

    private func filledPhotoSlot(at index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            DNAsyncImage(
                url: URL(string: viewModel.photos[index]),
                height: 140
            )
            .dnNeuRaised(intensity: .medium, cornerRadius: DNRadius.md)

            // Remove button
            Button {
                viewModel.removePhoto(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.dnDestructive)
                    .background(Circle().fill(Color.white))
            }
            .offset(x: 6, y: -6)
        }
    }

    private var emptyPhotoSlot: some View {
        Button {
            viewModel.addPhoto()
        } label: {
            RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                .strokeBorder(Color.dnBorder, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                .frame(height: 140)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.dnTextTertiary)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 2: About You

    private var aboutStep: some View {
        VStack(spacing: DNSpace.xl) {
            Text("Tell Us About You")
                .dnH2()

            VStack(spacing: DNSpace.lg) {
                // Bio (multiline)
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("BIO")
                        .dnLabel()
                        .textCase(.uppercase)

                    multilineTextField(
                        placeholder: "Tell others about yourself...",
                        text: $viewModel.bio
                    )
                }

                // Occupation
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("OCCUPATION")
                        .dnLabel()
                        .textCase(.uppercase)

                    DNTextField(
                        placeholder: "What do you do?",
                        text: $viewModel.occupation,
                        icon: "briefcase"
                    )
                }

                // Location
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("LOCATION")
                        .dnLabel()
                        .textCase(.uppercase)

                    DNTextField(
                        placeholder: "City, State",
                        text: $viewModel.location,
                        icon: "mappin.and.ellipse"
                    )
                }

                // Height
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("HEIGHT")
                        .dnLabel()
                        .textCase(.uppercase)

                    DNTextField(
                        placeholder: "Height in inches",
                        text: $viewModel.height,
                        icon: "ruler"
                    )
                    .keyboardType(.numberPad)
                }
            }
        }
    }

    private func multilineTextField(placeholder: String, text: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(-0.47)
                    .foregroundColor(.dnTextTertiary)
                    .padding(.top, 16)
                    .padding(.leading, 20)
            }

            TextEditor(text: text)
                .font(.system(size: 16, weight: .semibold))
                .tracking(-0.47)
                .foregroundColor(.dnTextPrimary)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .frame(height: 120)
        .dnNeuPressed(intensity: .medium, cornerRadius: DNRadius.md)
    }

    // MARK: - Step 3: Interests

    private var interestsStep: some View {
        VStack(spacing: DNSpace.xl) {
            Text("Pick Your Interests")
                .dnH2()

            Text("Choose at least 3 interests")
                .dnBody()

            FlowLayout(spacing: DNSpace.md) {
                ForEach(ProfileSetupViewModel.allInterests, id: \.self) { interest in
                    interestChip(interest)
                }
            }
        }
    }

    private func interestChip(_ interest: String) -> some View {
        let isSelected = viewModel.selectedInterests.contains(interest)

        return Button {
            viewModel.toggleInterest(interest)
        } label: {
            Text(interest)
                .font(.system(size: 14, weight: .bold))
                .tracking(0.2)
                .foregroundColor(isSelected ? .white : .dnTextSecondary)
                .padding(.horizontal, DNSpace.xl)
                .padding(.vertical, DNSpace.md)
        }
        .buttonStyle(.plain)
        .background(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                        .fill(Color.dnPrimary)
                }
            }
        )
        .modifier(InterestChipStyle(isSelected: isSelected))
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: DNSpace.lg) {
            if viewModel.currentStep > 0 {
                DNButton("Back", variant: .secondary) {
                    viewModel.previousStep()
                }
            }

            if viewModel.currentStep < ProfileSetupViewModel.totalSteps - 1 {
                DNButton("Next", variant: .primary) {
                    viewModel.nextStep()
                }
                .opacity(viewModel.canProceed ? 1.0 : 0.5)
                .allowsHitTesting(viewModel.canProceed)
            } else {
                DNButton("Complete Setup", variant: .primary) {
                    Task {
                        await viewModel.completeSetup()
                        profileComplete = true
                    }
                }
                .opacity(viewModel.canProceed ? 1.0 : 0.5)
                .allowsHitTesting(viewModel.canProceed)
            }
        }
    }
}

// MARK: - Interest Chip Style

private struct InterestChipStyle: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        if isSelected {
            content.dnNeuPressed(intensity: .medium, cornerRadius: DNRadius.md)
        } else {
            content.dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.md)
        }
    }
}

#Preview {
    ProfileSetupView()
}
