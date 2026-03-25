import SwiftUI

struct UserProfileModal: View {
    let user: MockUser
    @Environment(\.dismiss) private var dismiss
    @State private var currentPhotoIndex: Int = 0
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.dnBackground.ignoresSafeArea()

            // Photo gallery
            TabView(selection: $currentPhotoIndex) {
                ForEach(Array(user.photos.enumerated()), id: \.offset) { index, photo in
                    GeometryReader { geo in
                        DNAsyncImage(
                            url: URL(string: photo),
                            height: geo.size.height,
                            cornerRadius: 0
                        )
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Tap zones for navigation
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentPhotoIndex = max(0, currentPhotoIndex - 1)
                        }
                    }
                    .frame(maxWidth: .infinity)

                Color.clear
                    .frame(maxWidth: .infinity)

                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentPhotoIndex = min(user.photos.count - 1, currentPhotoIndex + 1)
                        }
                    }
                    .frame(maxWidth: .infinity)
            }

            // Overlays
            VStack {
                // Photo indicator bar
                HStack(spacing: 6) {
                    ForEach(0 ..< user.photos.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPhotoIndex ? Color.dnPrimary : Color.white.opacity(0.3))
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.2), value: currentPhotoIndex)
                    }
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.top, 60)

                Spacer()

                // Bottom overlay
                ZStack(alignment: .bottom) {
                    GradientOverlay(opacity: 0.8)
                        .frame(height: 320)

                    VStack(alignment: .leading, spacing: DNSpace.md) {
                        // Name + age
                        Text("\(user.name), \(user.age)")
                            .font(.system(size: 30, weight: .heavy))
                            .tracking(-0.6)
                            .foregroundColor(.white)

                        // Bio
                        Text(user.bio)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))

                        // Interests
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DNSpace.sm) {
                                ForEach(user.interests, id: \.self) { interest in
                                    DNOverlayChip(text: interest.uppercased())
                                }
                            }
                        }

                        // Action buttons
                        HStack(spacing: DNSpace.lg) {
                            // Pass
                            Button {} label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.dnDestructive)
                                    .frame(width: 56, height: 56)
                                    .dnNeuRaised(intensity: .medium, cornerRadius: DNRadius.full)
                            }

                            Spacer()

                            // Like
                            Button {} label: {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.dnAccentPink)
                                    .frame(width: 64, height: 64)
                                    .dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.full)
                            }

                            Spacer()

                            // Message
                            Button {} label: {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.dnInfo)
                                    .frame(width: 56, height: 56)
                                    .dnNeuRaised(intensity: .medium, cornerRadius: DNRadius.full)
                            }
                        }
                        .padding(.horizontal, DNSpace.xl)
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.bottom, DNSpace.xxl * 2)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.dnTextPrimary)
                            .frame(width: 36, height: 36)
                            .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                    }
                    .padding(.trailing, DNSpace.lg)
                    .padding(.top, 56)
                }
                Spacer()
            }
        }
        .scaleEffect(appeared ? 1.0 : 0.9)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.dnModalPresent) {
                appeared = true
            }
        }
    }
}
