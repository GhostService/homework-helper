import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    var isInitialSetup: Bool

    @State private var keyInputs: [AIProvider: String] = [:]
    @State private var savedProvider: AIProvider? = nil
    @State private var showError = false
    @State private var errorText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            if isInitialSetup {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome to HomeworkHelper")
                            .font(.headline)
                        Text("The Free option works with no setup. Add API keys for other providers to unlock more powerful models.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            ForEach(AIProvider.allCases) { provider in
                if provider.requiresAPIKey {
                    keyedProviderSection(provider)
                } else {
                    freeProviderSection(provider)
                }
            }

            Section("About") {
                LabeledContent("App", value: "HomeworkHelper")
            }
        }
        .navigationTitle(isInitialSetup ? "Setup" : "Settings")
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

    // MARK: - Free / keyless provider

    @ViewBuilder
    private func freeProviderSection(_ provider: AIProvider) -> some View {
        Section {
            HStack {
                Label(provider.rawValue, systemImage: provider.icon)
                    .font(.headline)
                Spacer()
                Label("Ready", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .labelStyle(.titleAndIcon)
            }

            Text(provider.pricingNote)
                .font(.caption)
                .foregroundStyle(.secondary)

            Label("No API key required. Works out of the box.", systemImage: "lock.open.fill")
                .font(.caption)
                .foregroundStyle(.green)
        }
    }

    // MARK: - Key-required providers

    @ViewBuilder
    private func keyedProviderSection(_ provider: AIProvider) -> some View {
        let hasKey = viewModel.hasAPIKey(for: provider)
        Section {
            HStack {
                Label(provider.rawValue, systemImage: provider.icon)
                    .font(.headline)
                Spacer()
                if hasKey {
                    Label("Configured", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .labelStyle(.iconOnly)
                }
            }

            Text(provider.pricingNote)
                .font(.caption)
                .foregroundStyle(.secondary)

            SecureField(provider.apiKeyPlaceholder, text: Binding(
                get: { keyInputs[provider] ?? "" },
                set: { keyInputs[provider] = $0 }
            ))
            .textContentType(.password)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            HStack(spacing: 12) {
                Button("Save") { saveKey(for: provider) }
                    .disabled((keyInputs[provider] ?? "").trimmingCharacters(in: .whitespaces).isEmpty)

                if hasKey {
                    Button("Remove", role: .destructive) { deleteKey(for: provider) }
                }

                Spacer()

                if savedProvider == provider {
                    Label("Saved", systemImage: "checkmark")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .transition(.opacity)
                }
            }

            Link("Get API key →", destination: URL(string: provider.getKeyURLString)!)
                .font(.caption)
        }
    }

    // MARK: - Actions

    private func saveKey(for provider: AIProvider) {
        let key = (keyInputs[provider] ?? "").trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return }
        do {
            try viewModel.saveAPIKey(key, for: provider)
            keyInputs[provider] = ""
            withAnimation { savedProvider = provider }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { if savedProvider == provider { savedProvider = nil } }
            }
            if isInitialSetup { dismiss() }
        } catch {
            errorText = error.localizedDescription
            showError = true
        }
    }

    private func deleteKey(for provider: AIProvider) {
        do {
            try viewModel.deleteAPIKey(for: provider)
        } catch {
            errorText = error.localizedDescription
            showError = true
        }
    }
}
