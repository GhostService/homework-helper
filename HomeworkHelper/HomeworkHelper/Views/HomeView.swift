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
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundStyle(.accentColor)
            Text("What are you studying?")
                .font(.title2)
                .bold()
            Text("Powered by Claude Haiku")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 32)
    }

    private var subjectPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Subject")
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
