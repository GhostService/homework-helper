import UIKit

private let baseSystemPrompt = """
You are an expert homework and study assistant supporting K-12 and college students across all subjects. Your goal is to help students UNDERSTAND concepts, not just get answers.

RESPONSE FORMAT:
- Always structure responses with clear sections
- For math/science problems: show step-by-step working with each step numbered and explained
- Use plain text math notation (e.g., x^2 + 3x + 2 = 0) since this is a mobile interface
- Bold key terms using **bold**
- End with "Answer: [final answer]" on its own line
- Add a brief "Key Concept:" note explaining the underlying principle after the answer

BEHAVIOR:
- When given an image of a problem, analyze it carefully before responding
- State what subject/topic the problem is about at the start
- If the image is unclear, ask for clarification
- Never just give the answer without explanation
- If asked follow-up questions, build on your previous explanation

SUBJECTS: Math, Physics, Chemistry, Biology, English/Writing, History, Computer Science, Economics, and more.
"""

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var selectedSubject: Subject = .general
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showSettings: Bool = false
    @Published var apiKeyConfigured: Bool = false

    private let anthropicService = AnthropicService()

    init() {
        checkAPIKeyExists()
    }

    func checkAPIKeyExists() {
        apiKeyConfigured = KeychainService.loadAPIKey() != nil
    }

    func saveAPIKey(_ key: String) throws {
        try KeychainService.saveAPIKey(key)
        apiKeyConfigured = true
    }

    func deleteAPIKey() throws {
        try KeychainService.deleteAPIKey()
        apiKeyConfigured = false
    }

    func attachImage(_ image: UIImage) {
        selectedImage = image
    }

    func removeImage() {
        selectedImage = nil
    }

    func setSubject(_ subject: Subject) {
        selectedSubject = subject
    }

    func clearConversation() {
        messages = []
        inputText = ""
        selectedImage = nil
        errorMessage = nil
    }

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let image = selectedImage

        guard !text.isEmpty || image != nil else { return }
        guard !isLoading else { return }

        guard let apiKey = KeychainService.loadAPIKey(), !apiKey.isEmpty else {
            showSettings = true
            return
        }

        // Optimistic UI: clear input immediately
        inputText = ""
        selectedImage = nil
        errorMessage = nil

        let userMessage = ChatMessage(role: .user, text: text, image: image)
        messages.append(userMessage)

        let placeholder = ChatMessage(role: .assistant, text: "", isStreaming: true)
        messages.append(placeholder)
        isLoading = true

        do {
            let systemPrompt = buildSystemPrompt(for: selectedSubject)
            let response = try await anthropicService.sendMessage(
                history: messages.filter { !$0.isStreaming },
                systemPrompt: systemPrompt,
                apiKey: apiKey
            )
            // Replace placeholder with real response
            if let idx = messages.firstIndex(where: { $0.id == placeholder.id }) {
                messages[idx] = ChatMessage(role: .assistant, text: response)
            }
        } catch {
            // Remove placeholder on error
            messages.removeAll { $0.id == placeholder.id }
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    private func buildSystemPrompt(for subject: Subject) -> String {
        guard subject != .general, !subject.systemPromptHint.isEmpty else {
            return baseSystemPrompt
        }
        return subject.systemPromptHint + "\n\n" + baseSystemPrompt
    }
}
