import UIKit

/// Handles OpenAI, OpenRouter, Pollinations (Free), and any other OpenAI-compatible provider.
actor OpenAICompatibleService {
    private static let maxTokens = 2048
    private static let maxHistoryMessages = 10
    private static let maxImageDimension: CGFloat = 1568

    func sendMessage(
        history: [ChatMessage],
        systemPrompt: String,
        apiKey: String?,
        provider: AIProvider
    ) async throws -> String {
        let request = try buildURLRequest(
            history: history,
            systemPrompt: systemPrompt,
            apiKey: apiKey,
            provider: provider
        )
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.networkError("Invalid response")
        }

        switch httpResponse.statusCode {
        case 200:
            let decoded = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
            return decoded.textContent
        case 401:
            throw AppError.invalidAPIKey
        case 429:
            throw AppError.rateLimited
        case 500...599:
            throw AppError.serverError(httpResponse.statusCode)
        default:
            let body = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AppError.apiError(body)
        }
    }

    private func buildURLRequest(
        history: [ChatMessage],
        systemPrompt: String,
        apiKey: String?,
        provider: AIProvider
    ) throws -> URLRequest {
        guard let url = URL(string: provider.apiEndpoint) else {
            throw AppError.networkError("Invalid endpoint URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Only attach Authorization header when the provider actually needs a key
        if provider.requiresAPIKey, let key = apiKey, !key.isEmpty {
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        if provider == .openRouter {
            request.setValue("HomeworkHelper", forHTTPHeaderField: "X-Title")
        }

        let messages = try buildMessages(history: history, systemPrompt: systemPrompt)
        let body = OpenAIChatRequest(
            model: provider.defaultModel,
            messages: messages,
            maxTokens: Self.maxTokens
        )
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func buildMessages(
        history: [ChatMessage],
        systemPrompt: String
    ) throws -> [OpenAIMessage] {
        var messages: [OpenAIMessage] = [
            OpenAIMessage(role: "system", content: .text(systemPrompt))
        ]
        let trimmed = Array(history.suffix(Self.maxHistoryMessages))
        for msg in trimmed {
            switch msg.role {
            case .user:
                if let image = msg.image {
                    let resized = resizeImage(image)
                    guard let jpegData = resized.jpegData(compressionQuality: 0.8) else {
                        throw AppError.imageEncodingFailed
                    }
                    let dataURI = "data:image/jpeg;base64," + jpegData.base64EncodedString()
                    var blocks: [OpenAIContentBlock] = [.imageURL(dataURI)]
                    if !msg.text.isEmpty { blocks.append(.text(msg.text)) }
                    messages.append(OpenAIMessage(role: "user", content: .blocks(blocks)))
                } else {
                    messages.append(OpenAIMessage(role: "user", content: .text(msg.text)))
                }
            case .assistant:
                messages.append(OpenAIMessage(role: "assistant", content: .text(msg.text)))
            }
        }
        return messages
    }

    private func resizeImage(_ image: UIImage) -> UIImage {
        let maxDim = Self.maxImageDimension
        let size = image.size
        guard size.width > maxDim || size.height > maxDim else { return image }
        let scale = min(maxDim / size.width, maxDim / size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}
