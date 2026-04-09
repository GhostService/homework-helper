import SwiftUI
import AVFoundation

struct LiveCameraHomeView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @StateObject private var camera = CameraManager()

    @State private var navigateToChat = false
    @State private var showImagePicker = false
    @State private var showTextInput = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // ── Full-screen live viewfinder ──────────────────────────────
            if camera.permissionGranted {
                CameraPreviewView(session: camera.session)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                permissionDeniedOverlay
            }

            // ── HUD overlay ─────────────────────────────────────────────
            VStack {
                topBar
                Spacer()
                bottomControls
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            camera.requestPermissionAndSetup()
            viewModel.clearConversation()
        }
        .onDisappear { camera.stopSession() }
        .navigationDestination(isPresented: $navigateToChat) {
            ChatView()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: Binding(
                get: { viewModel.selectedImage },
                set: { img in
                    viewModel.selectedImage = img
                    if img != nil { navigateToChat = true }
                }
            ))
        }
        .sheet(isPresented: $showTextInput) {
            textInputSheet
        }
        .sheet(isPresented: $viewModel.showSettings) {
            NavigationStack { SettingsView(isInitialSetup: false) }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            // Provider badge
            providerBadge

            Spacer()

            // Settings
            glassCircleButton(icon: "gear") {
                viewModel.showSettings = true
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)          // clear Dynamic Island / notch
    }

    private var providerBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: viewModel.selectedProvider.icon)
                .font(.footnote.weight(.semibold))
            Text(viewModel.selectedProvider.rawValue)
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassCard(cornerRadius: 20)
    }

    // MARK: - Bottom controls

    private var bottomControls: some View {
        HStack(alignment: .center) {
            // Photo library
            glassCircleButton(icon: "photo.on.rectangle") {
                showImagePicker = true
            }

            Spacer()

            // Shutter button
            shutterButton

            Spacer()

            // Flash toggle
            glassCircleButton(icon: camera.flashOn ? "bolt.fill" : "bolt.slash.fill") {
                camera.toggleFlash()
            }
        }
        .padding(.horizontal, 36)
        .padding(.bottom, 48)
    }

    private var shutterButton: some View {
        Button {
            camera.capturePhoto { image in
                guard let image else { return }
                viewModel.selectedImage = image
                navigateToChat = true
            }
        } label: {
            ZStack {
                // Outer ring
                Circle()
                    .strokeBorder(.white.opacity(0.9), lineWidth: 3)
                    .frame(width: 76, height: 76)
                // Inner fill
                Circle()
                    .fill(.white)
                    .frame(width: 64, height: 64)
                // Icon
                Image(systemName: "viewfinder")
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(.black.opacity(0.8))
            }
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
    }

    // MARK: - Text input sheet

    private var textInputSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Ask any question…", text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(3...8)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)

                Button {
                    showTextInput = false
                    navigateToChat = true
                } label: {
                    Label("Ask", systemImage: "arrow.up.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .fontWeight(.semibold)
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)
            }
            .padding(.top, 24)
            .navigationTitle("Type a Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showTextInput = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Permission denied

    private var permissionDeniedOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Camera Access Required")
                .font(.headline)
            Text("Enable camera access in Settings to scan problems.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }

    // MARK: - Helpers

    private func glassCircleButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .glassCard(cornerRadius: 25)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Liquid Glass modifier

private extension View {
    /// Applies Liquid Glass on iOS 26+, falls back to ultraThinMaterial on earlier OS.
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        if #available(iOS 26, *) {
            self.background(.clear)
                .glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            self.background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius)
            )
        }
    }
}
