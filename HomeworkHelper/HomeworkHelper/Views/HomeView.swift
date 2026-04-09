import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var navigateToChat = false
    @State private var showImagePicker = false
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer()
            providerPicker
            subjectPicker
            Spacer()
            ctaButtons
            quickTextEntry
        }
        .navigationTitle("Homework Helper")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.showSettings = true }) {
                    Image(systemName: "gear")
                }
            }
        }
        .navigationDestination(isPresented: $navigateToChat) {
            ChatView()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: Binding(
                get: { viewModel.selectedImage },
                set: { image in
                    viewModel.selectedImage = image
                    if image != nil { navigateToChat = true }
                }
            ))
        }
        .sheet(isPresented: $showCamera) {
            CameraView(image: Binding(
                get: { viewModel.selectedImage },
                set: { image in
                    viewModel.selectedImage = image
                    if image != nil { navigateToChat = true }
                }
            ))
        }
        .onAppear {
            viewModel.clearConversation()
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 56))
                .foregroundStyle(.accentColor)
            Text("What are you studying?")
                .font(.title2)
                .bold()
        }
        .padding(.top, 28)
    }

    private var providerPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI Provider")
                .font(.headline)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AIProvider.allCases) { provider in
                        ProviderChip(
                            provider: provider,
                            isSelected: viewModel.selectedProvider == provider,
                            isConfigured: viewModel.isProviderReady(provider)
                        ) {
                            viewModel.setProvider(provider)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
        .padding(.bottom, 8)
    }

    private var subjectPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subject")
                .font(.headline)
                .padding(.horizontal, 16)
            SubjectSelectorView(selectedSubject: $viewModel.selectedSubject)
        }
    }

    private var ctaButtons: some View {
        VStack(spacing: 12) {
            Button(action: { showCamera = true }) {
                Label("Take Photo of Problem", systemImage: "camera.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .fontWeight(.semibold)
            }
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

            Button(action: { showImagePicker = true }) {
                Label("Upload Image", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 20)
    }

    private var quickTextEntry: some View {
        HStack(spacing: 8) {
            TextField("Or type your question here...", text: $viewModel.inputText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onSubmit { navigateToChat = true }

            Button(action: { navigateToChat = true }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : .accentColor)
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Provider Chip

private struct ProviderChip: View {
    let provider: AIProvider
    let isSelected: Bool
    let isConfigured: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: provider.icon)
                    .font(.footnote)
                Text(provider.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                if isConfigured {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .green)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
