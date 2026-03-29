import PhotosUI
import SwiftUI

struct AddEventView: View {
    @StateObject private var viewModel: AddEventViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(event: Event? = nil) {
        _viewModel = StateObject(wrappedValue: AddEventViewModel(event: event))
    }

    var body: some View {
        NavigationStack {
            DNScreen {
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: DNSpace.xl) {
                            eventDetailsSection
                            dateTimeSection
                            locationSection
                            imageSection
                            priceSection
                            capacitySection
                            visibilitySection
                        }
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.top, DNSpace.md)
                        .padding(.bottom, 120)
                    }

                    stickyCreateButton
                }
            }
            .navigationTitle(viewModel.isEditing ? "add_event_edit_title".localized() : "add_event_create_title"
                .localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.dnTextPrimary)
                    }
                }
            }
            .onChange(of: viewModel.didCreate) { created in
                if created { dismiss() }
            }
        }
    }

    // MARK: - Event Details

    private var eventDetailsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("add_event_details".localized())
                .dnH3()

            DNTextField(
                placeholder: "add_event_title_placeholder".localized(),
                text: $viewModel.title,
                icon: "pencil"
            )

            descriptionField

            Text("add_event_category".localized())
                .dnLabel()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DNSpace.sm) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        FilterChip(
                            title: category,
                            isActive: Binding(
                                get: { viewModel.selectedCategory == category },
                                set: { active in
                                    if active { viewModel.selectedCategory = category }
                                }
                            )
                        )
                    }
                }
            }
        }
    }

    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            TextEditor(text: $viewModel.description)
                .font(.system(size: 16, weight: .semibold))
                .tracking(-0.47)
                .foregroundColor(.dnTextPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .padding(.horizontal, DNSpace.lg)
                .padding(.vertical, DNSpace.md)
                .dnNeuPressed(intensity: .medium, cornerRadius: DNRadius.md)
                .overlay(alignment: .topLeading) {
                    if viewModel.description.isEmpty {
                        Text("add_event_description_placeholder".localized())
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(-0.47)
                            .foregroundColor(.dnTextTertiary)
                            .padding(.horizontal, DNSpace.lg)
                            .padding(.vertical, DNSpace.lg)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - Date & Time

    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("add_event_date_time".localized())
                .dnH3()

            DNCard {
                VStack(spacing: DNSpace.lg) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.dnPrimary)
                        Text("add_event_date".localized())
                            .dnBody()
                        Spacer()
                        DatePicker(
                            "",
                            selection: $viewModel.eventDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .tint(.dnPrimary)
                    }

                    Divider()

                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.dnPrimary)
                        Text("add_event_time".localized())
                            .dnBody()
                        Spacer()
                        DatePicker(
                            "",
                            selection: $viewModel.eventTime,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .tint(.dnPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("add_event_location".localized())
                .dnH3()

            DNTextField(
                placeholder: "add_event_venue_placeholder".localized(),
                text: $viewModel.venue,
                icon: "building.2"
            )

            DNTextField(
                placeholder: "add_event_address_placeholder".localized(),
                text: $viewModel.location,
                icon: "mappin.and.ellipse"
            )
        }
    }

    // MARK: - Image

    private var imageSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("add_event_image".localized())
                .dnH3()

            DNCard {
                if let image = viewModel.selectedImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(
                                RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                            )

                        Button {
                            viewModel.selectedImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.dnDestructive)
                                .background(Circle().fill(Color.white))
                        }
                        .offset(x: -8, y: 8)
                    }
                } else {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: DNSpace.md) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.dnTextTertiary)
                            Text("add_event_tap_photo".localized())
                                .dnBody()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                                .stroke(
                                    Color.dnBorder,
                                    style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        guard let newItem else { return }
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data) {
                                    viewModel.selectedImage = uiImage
                                }
                            }
                            selectedPhotoItem = nil
                        }
                    }
                }
            }
        }
    }

    // MARK: - Price

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("add_event_price".localized())
                .dnH3()

            DNTextField(
                placeholder: "add_event_price_free".localized(),
                text: $viewModel.price,
                icon: "dollarsign"
            )
        }
    }

    // MARK: - Capacity

    private var capacitySection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("add_event_capacity".localized())
                .dnH3()

            DNTextField(
                placeholder: "100",
                text: $viewModel.totalSpots,
                icon: "person.2"
            )
            .keyboardType(.numberPad)

            Text("add_event_capacity_hint".localized())
                .dnSmall()
        }
    }

    // MARK: - Visibility

    private var visibilitySection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("add_event_visibility".localized())
                .dnH3()

            DNCard {
                VStack(alignment: .leading, spacing: DNSpace.md) {
                    Toggle(isOn: $viewModel.isPublic) {
                        HStack(spacing: DNSpace.md) {
                            Image(systemName: viewModel.isPublic ? "globe" : "lock.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.dnPrimary)
                            Text(viewModel.isPublic ? "add_event_public".localized() : "add_event_private".localized())
                                .dnBody()
                        }
                    }
                    .tint(.dnPrimary)

                    Text(
                        viewModel.isPublic
                            ? "add_event_public_desc".localized()
                            : "add_event_private_desc".localized()
                    )
                    .dnSmall()
                }
            }
        }
    }

    // MARK: - Create Button

    private var stickyCreateButton: some View {
        VStack(spacing: 0) {
            DNButton(
                viewModel.isEditing ? "add_event_save".localized() : "add_event_create".localized(),
                variant: .primary
            ) {
                Task { await viewModel.save() }
            }
            .padding(.horizontal, DNSpace.xl)
            .padding(.vertical, DNSpace.lg)
            .background(Color.dnBackground)
            .dnNeuRaised(intensity: .medium, cornerRadius: 0)
        }
        .opacity(viewModel.isValid ? 1.0 : 0.5)
        .allowsHitTesting(viewModel.isValid && !viewModel.isCreating)
    }
}
