import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showImageSourceMenu = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            messageList
            Divider()
            inputBar
        }
        .navigationTitle(viewModel.selectedSubject.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.clearConversation() }) {
                    Image(systemName: "square.and.pencil")
                }
                .disabled(viewModel.messages.isEmpty)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.showSettings = true }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $viewModel.selectedImage)
        }
        .sheet(isPresented: $showCamera) {
            CameraView(image: $viewModel.selectedImage)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.messages.isEmpty {
                        emptyState
                    }
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let last = viewModel.messages.last {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("Ask any homework question")
                .font(.title3)
                .bold()
            Text("Type a question or attach a photo of your problem.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, 32)
    }

    private var inputBar: some View {
        VStack(spacing: 0) {
            if let image = viewModel.selectedImage {
                imagePreview(image)
            }
            HStack(alignment: .bottom, spacing: 8) {
                Button(action: { showImageSourceMenu = true }) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title3)
                        .foregroundStyle(.accentColor)
                }
                .confirmationDialog("Attach Image", isPresented: $showImageSourceMenu) {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button("Take Photo") { showCamera = true }
                    }
                    Button("Choose from Library") { showImagePicker = true }
                    Button("Cancel", role: .cancel) {}
                }
                .padding(.bottom, 8)

                TextField("Ask a question...", text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .focused($inputFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Button(action: {
                    inputFocused = false
                    Task { await viewModel.sendMessage() }
                }) {
                    Image(systemName: viewModel.isLoading ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(canSend ? .accentColor : .secondary)
                }
                .disabled(!canSend)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(.regularMaterial)
    }

    private var canSend: Bool {
        !viewModel.isLoading &&
        (!viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.selectedImage != nil)
    }

    private func imagePreview(_ image: UIImage) -> some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(alignment: .topTrailing) {
                    Button(action: { viewModel.removeImage() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white, .black)
                            .font(.footnote)
                    }
                    .offset(x: 6, y: -6)
                }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
