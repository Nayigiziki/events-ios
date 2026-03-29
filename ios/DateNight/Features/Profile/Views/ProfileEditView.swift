import PhotosUI
import SwiftUI

struct ProfileEditView: View {
    @StateObject private var viewModel = ProfileEditViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?

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
                    DNButton("profile_edit_save".localized(), variant: .primary) {
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
        .task {
            await viewModel.loadCurrentUser()
        }
        .navigationTitle("profile_edit".localized())
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
            Text("profile_edit_photos_title".localized())
                .dnH3()

            LazyVGrid(columns: columns, spacing: DNSpace.md) {
                ForEach(Array(viewModel.photos.enumerated()), id: \.offset) { index, photo in
                    ZStack(alignment: .topTrailing) {
                        DNAsyncImage(
                            url: URL(string: photo),
                            height: 120
                        )
                        .aspectRatio(1, contentMode: .fill)
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.md)

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

                if viewModel.photos.count < ProfileEditViewModel.maxPhotos {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        VStack(spacing: DNSpace.sm) {
                            if viewModel.isUploadingPhoto {
                                ProgressView()
                                    .tint(.dnPrimary)
                            } else {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.dnTextTertiary)
                                Text("profile_edit_photos_add".localized())
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.dnTextTertiary)
                                    .textCase(.uppercase)
                            }
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
            }

            Text("profile_edit_photos_hint".localized())
                .dnSmall()
        }
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("profile_edit_basic_info".localized())
                .dnH3()

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text("profile_edit_name".localized())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                    .textCase(.uppercase)
                DNTextField(
                    placeholder: "profile_edit_name_placeholder".localized(),
                    text: $viewModel.name,
                    icon: "person.fill"
                )
            }

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text("profile_edit_bio".localized())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                    .textCase(.uppercase)
                TextField("profile_edit_bio_placeholder".localized(), text: $viewModel.bio, axis: .vertical)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.dnTextPrimary)
                    .lineLimit(4 ... 6)
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.md)
                    .dnNeuPressed(cornerRadius: DNRadius.md)
            }

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text("profile_edit_occupation".localized())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                    .textCase(.uppercase)
                DNTextField(
                    placeholder: "profile_edit_occupation_placeholder".localized(),
                    text: $viewModel.occupation,
                    icon: "briefcase.fill"
                )
            }

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text("profile_edit_height".localized())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                    .textCase(.uppercase)
                DNTextField(
                    placeholder: "profile_edit_height_placeholder".localized(),
                    text: $viewModel.height,
                    icon: "ruler"
                )
            }
        }
    }

    // MARK: - Interests Section

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            Text("profile_edit_interests".localized())
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
                DNTextField(placeholder: "profile_edit_add_interest".localized(), text: $viewModel.newInterest)

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
                        Text("profile_edit_ready_to_mingle".localized())
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.dnTextPrimary)
                            .textCase(.uppercase)
                        Text("profile_edit_ready_subtitle".localized())
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
                            "profile_edit_available_from".localized(),
                            selection: $viewModel.availableFrom,
                            displayedComponents: .date
                        )
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.dnTextPrimary)

                        DatePicker(
                            "profile_edit_available_until".localized(),
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
