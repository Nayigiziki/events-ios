import SwiftUI

struct AddEventView: View {
    @StateObject private var viewModel = AddEventViewModel()
    @Environment(\.dismiss) private var dismiss

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
                            visibilitySection
                        }
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.top, DNSpace.md)
                        .padding(.bottom, 120)
                    }

                    stickyCreateButton
                }
            }
            .navigationTitle("Create Event")
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
            Text("Event Details")
                .dnH3()

            DNTextField(
                placeholder: "Event title",
                text: $viewModel.title,
                icon: "pencil"
            )

            descriptionField

            Text("Category")
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
                        Text("Describe your event...")
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
            Text("Date & Time")
                .dnH3()

            DNCard {
                VStack(spacing: DNSpace.lg) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.dnPrimary)
                        Text("Date")
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
                        Text("Time")
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
            Text("Location")
                .dnH3()

            DNTextField(
                placeholder: "Venue name",
                text: $viewModel.venue,
                icon: "building.2"
            )

            DNTextField(
                placeholder: "Address",
                text: $viewModel.location,
                icon: "mappin.and.ellipse"
            )
        }
    }

    // MARK: - Image

    private var imageSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("Image")
                .dnH3()

            DNCard {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(
                            RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                        )
                } else {
                    Button {} label: {
                        VStack(spacing: DNSpace.md) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.dnTextTertiary)
                            Text("Tap to add a photo")
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
                }
            }
        }
    }

    // MARK: - Price

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("Price")
                .dnH3()

            DNTextField(
                placeholder: "Free",
                text: $viewModel.price,
                icon: "dollarsign"
            )
        }
    }

    // MARK: - Visibility

    private var visibilitySection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("Visibility")
                .dnH3()

            DNCard {
                VStack(alignment: .leading, spacing: DNSpace.md) {
                    Toggle(isOn: $viewModel.isPublic) {
                        HStack(spacing: DNSpace.md) {
                            Image(systemName: viewModel.isPublic ? "globe" : "lock.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.dnPrimary)
                            Text(viewModel.isPublic ? "Public" : "Private")
                                .dnBody()
                        }
                    }
                    .tint(.dnPrimary)

                    Text(
                        viewModel.isPublic
                            ? "Anyone on DateNight can discover this event."
                            : "Only people you invite can see this event."
                    )
                    .dnSmall()
                }
            }
        }
    }

    // MARK: - Create Button

    private var stickyCreateButton: some View {
        VStack(spacing: 0) {
            DNButton("Create Event", variant: .primary) {
                Task { await viewModel.createEvent() }
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
