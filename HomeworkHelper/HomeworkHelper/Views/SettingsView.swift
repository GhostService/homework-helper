import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    var isInitialSetup: Bool

    @State private var apiKeyInput: String = ""
    @State private var showError: Bool = false
    @State private var errorText: String = ""
    @State private var saved: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Anthropic API Key")
                        .font(.headline)
                    Text("Get your free API key from the Anthropic Console.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)

                SecureField("sk-ant-...", text: $apiKeyInput)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                Button(action: saveKey) {
                    HStack {
                        Spacer()
                        Text("Save API Key")
                            .bold()
                        Spacer()
                    }
                }
                .disabled(apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty)

                if saved {
                    Label("API key saved successfully.", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.footnote)
                }
            }

            if viewModel.apiKeyConfigured && !isInitialSetup {
                Section("Danger Zone") {
                    Button(role: .destructive, action: deleteKey) {
                        Label("Remove API Key", systemImage: "trash")
                    }
                }
            }

            Section("About") {
                LabeledContent("Model", value: AnthropicService.model)
                LabeledContent("App", value: "Homework Helper")
            }
        }
        .navigationTitle(isInitialSetup ? "Welcome" : "Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !isInitialSetup {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorText)
        }
    }

    private func saveKey() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return }
        do {
            try viewModel.saveAPIKey(key)
            saved = true
            apiKeyInput = ""
            if !isInitialSetup {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            }
        } catch {
            errorText = error.localizedDescription
            showError = true
        }
    }

    private func deleteKey() {
        do {
            try viewModel.deleteAPIKey()
        } catch {
            errorText = error.localizedDescription
            showError = true
        }
    }
}
