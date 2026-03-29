import PhotosUI
import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileSetupViewModel()
    @State private var selectedItem: PhotosPickerItem?

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
        .onAppear {
            viewModel.userId = authViewModel.userId
        }
        .onChange(of: viewModel.isComplete) { _, newValue in
            if newValue {
                authViewModel.profileComplete = true
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
            Text("setup_photos_title".localized())
                .dnH2()

            Text("setup_photos_subtitle".localized())
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
        PhotosPicker(selection: $selectedItem, matching: .images) {
            RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                .strokeBorder(Color.dnBorder, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                .frame(height: 140)
                .overlay(
                    Group {
                        if viewModel.isUploadingPhoto {
                            ProgressView()
                                .tint(.dnPrimary)
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.dnTextTertiary)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isUploadingPhoto)
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await viewModel.addPhotoData(data)
                }
                selectedItem = nil
            }
        }
    }

    // MARK: - Step 2: About You

    private var aboutStep: some View {
        VStack(spacing: DNSpace.xl) {
            Text("setup_about_title".localized())
                .dnH2()

            VStack(spacing: DNSpace.lg) {
                // Bio (multiline)
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("setup_bio".localized())
                        .dnLabel()
                        .textCase(.uppercase)

                    multilineTextField(
                        placeholder: "setup_bio_placeholder".localized(),
                        text: $viewModel.bio
                    )
                }

                // Occupation
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("setup_occupation".localized())
                        .dnLabel()
                        .textCase(.uppercase)

                    DNTextField(
                        placeholder: "setup_occupation_placeholder".localized(),
                        text: $viewModel.occupation,
                        icon: "briefcase"
                    )
                }

                // Location
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("setup_location".localized())
                        .dnLabel()
                        .textCase(.uppercase)

                    DNTextField(
                        placeholder: "setup_location_placeholder".localized(),
                        text: $viewModel.location,
                        icon: "mappin.and.ellipse"
                    )
                }

                // Height
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("setup_height".localized())
                        .dnLabel()
                        .textCase(.uppercase)

                    DNTextField(
                        placeholder: "setup_height_placeholder".localized(),
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
            Text("setup_interests_title".localized())
                .dnH2()

            Text("setup_interests_subtitle".localized())
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
        VStack(spacing: DNSpace.sm) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .dnCaption()
                    .foregroundColor(.dnDestructive)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: DNSpace.lg) {
                if viewModel.currentStep > 0 {
                    DNButton("setup_back".localized(), variant: .secondary) {
                        viewModel.previousStep()
                    }
                }

                if viewModel.currentStep < ProfileSetupViewModel.totalSteps - 1 {
                    DNButton("setup_next".localized(), variant: .primary) {
                        viewModel.nextStep()
                    }
                    .opacity(viewModel.canProceed ? 1.0 : 0.5)
                    .allowsHitTesting(viewModel.canProceed)
                } else {
                    DNButton("setup_complete".localized(), variant: .primary) {
                        Task {
                            await viewModel.completeSetup()
                        }
                    }
                    .opacity(viewModel.canProceed ? 1.0 : 0.5)
                    .allowsHitTesting(viewModel.canProceed)
                }
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
