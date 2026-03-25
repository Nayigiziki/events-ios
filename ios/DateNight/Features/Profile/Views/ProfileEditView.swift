import SwiftUI

struct ProfileEditView: View {
    @StateObject private var viewModel = ProfileEditViewModel()
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: DNSpace.md), count: 3)

    var body: some View {
        DNScreen {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DNSpace.xl) {
                        photoGridSection
                        formSection
                        interestsSection
                        availabilitySection
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.top, DNSpace.lg)
                    .padding(.bottom, 100)
                }

                // Sticky save button
                VStack {
                    DNButton("Save Changes", variant: .primary) {
                        viewModel.saveProfile()
                        dismiss()
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.md)
                }
                .background(Color.dnBackground)
                .dnNeuRaised(intensity: .medium, cornerRadius: 0)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.dnTextPrimary)
                }
            }
        }
    }

    // MARK: - Photo Grid

    private var photoGridSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            Text("Your Photos")
                .dnH3()

            LazyVGrid(columns: columns, spacing: DNSpace.md) {
                ForEach(Array(viewModel.photos.enumerated()), id: \.offset) { index, photo in
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: photo)) { phase in
                            switch phase {
                            case let .success(image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            default:
                                Color.dnMuted
                            }
                        }
                        .frame(minHeight: 110)
                        .clipShape(RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous))
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.md)
                        .aspectRatio(1, contentMode: .fill)

                        Button {
                            viewModel.removePhoto(at: index)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(Color.dnDestructive))
                        }
                        .offset(x: 6, y: -6)
                    }
                }

                if viewModel.photos.count < 6 {
                    Button {
                        viewModel.addPhoto()
                    } label: {
                        VStack(spacing: DNSpace.sm) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.dnTextTertiary)
                            Text("Add")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.dnTextTertiary)
                                .textCase(.uppercase)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 110)
                        .aspectRatio(1, contentMode: .fill)
                        .overlay(
                            RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                .foregroundColor(.dnTextTertiary)
                        )
                        .dnNeuPressed(intensity: .light, cornerRadius: DNRadius.md)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("Min 2 photos, max 6")
                .dnSmall()
        }
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("Basic Info")
                .dnH3()

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text("Name")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                    .textCase(.uppercase)
                DNTextField(placeholder: "Your name", text: $viewModel.name, icon: "person.fill")
            }

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text("Bio")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                    .textCase(.uppercase)
                TextField("Tell us about yourself...", text: $viewModel.bio, axis: .vertical)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.dnTextPrimary)
                    .lineLimit(4 ... 6)
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.md)
                    .dnNeuPressed(cornerRadius: DNRadius.md)
            }

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text("Occupation")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                    .textCase(.uppercase)
                DNTextField(placeholder: "Your occupation", text: $viewModel.occupation, icon: "briefcase.fill")
            }

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text("Height (cm)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                    .textCase(.uppercase)
                DNTextField(placeholder: "Height in cm", text: $viewModel.height, icon: "ruler")
            }
        }
    }

    // MARK: - Interests Section

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            Text("Interests")
                .dnH3()

            FlowLayout(spacing: DNSpace.sm) {
                ForEach(viewModel.interests, id: \.self) { interest in
                    HStack(spacing: DNSpace.xs) {
                        Text(interest)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .textCase(.uppercase)

                        Button {
                            viewModel.removeInterest(interest)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.sm)
                    .background(
                        Capsule()
                            .fill(DNGradient.accentPill)
                    )
                }
            }

            HStack(spacing: DNSpace.sm) {
                DNTextField(placeholder: "Add interest...", text: $viewModel.newInterest)

                Button {
                    viewModel.addInterest()
                } label: {
                    Text("+")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(DNGradient.accentPill)
                        .clipShape(RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous))
                }
            }
        }
    }

    // MARK: - Availability Section

    private var availabilitySection: some View {
        DNCard {
            VStack(alignment: .leading, spacing: DNSpace.md) {
                HStack {
                    VStack(alignment: .leading, spacing: DNSpace.xs) {
                        Text("Ready to Mingle")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.dnTextPrimary)
                            .textCase(.uppercase)
                        Text("Are you looking to meet people?")
                            .dnCaption()
                    }

                    Spacer()

                    Toggle("", isOn: $viewModel.isReadyToMingle)
                        .tint(.dnPrimary)
                        .labelsHidden()
                }

                if viewModel.isReadyToMingle {
                    VStack(alignment: .leading, spacing: DNSpace.sm) {
                        DatePicker(
                            "From",
                            selection: $viewModel.availableFrom,
                            displayedComponents: .date
                        )
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.dnTextPrimary)

                        DatePicker(
                            "Until",
                            selection: $viewModel.availableUntil,
                            displayedComponents: .date
                        )
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.dnTextPrimary)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.dnCardEntry, value: viewModel.isReadyToMingle)
                }
            }
        }
    }
}
