import UIKit

actor AnthropicService {
    private static let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    static let model = "claude-haiku-4-5-20251001"
    private static let anthropicVersion = "2023-06-01"
    private static let maxTokens = 2048
    private static let maxHistoryMessages = 10
    private static let maxImageDimension: CGFloat = 1568

    func sendMessage(
        history: [ChatMessage],
        systemPrompt: String,
        apiKey: String
    ) async throws -> String {
        let request = try buildURLRequest(history: history, systemPrompt: systemPrompt, apiKey: apiKey)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.networkError("Invalid response")
        }

        switch httpResponse.statusCode {
        case 200:
            let decoded = try JSONDecoder().decode(AnthropicResponse.self, from: data)
            return decoded.textContent
        case 401:
            throw AppError.invalidAPIKey
        case 429:
            throw AppError.rateLimited
        case 500...599:
            throw AppError.serverError(httpResponse.statusCode)
        default:
            if let errorResponse = try? JSONDecoder().decode(AnthropicErrorResponse.self, from: data) {
                throw AppError.apiError(errorResponse.error.message)
            }
            throw AppError.serverError(httpResponse.statusCode)
        }
    }

    private func buildURLRequest(
        history: [ChatMessage],
        systemPrompt: String,
        apiKey: String
    ) throws -> URLRequest {
        var request = URLRequest(url: Self.apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(Self.anthropicVersion, forHTTPHeaderField: "anthropic-version")

        let messages = try buildMessages(from: history)
        let body = AnthropicRequest(
            model: Self.model,
            maxTokens: Self.maxTokens,
            system: systemPrompt,
            messages: messages
        )

        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func buildMessages(from history: [ChatMessage]) throws -> [RequestMessage] {
        let trimmed = Array(history.suffix(Self.maxHistoryMessages))
        return try trimmed.map { message in
            switch message.role {
            case .user:
                var blocks: [ContentBlock] = []
                if let image = message.image {
                    let resized = resizeImage(image)
                    guard let jpegData = resized.jpegData(compressionQuality: 0.8) else {
                        throw AppError.imageEncodingFailed
                    }
                    blocks.append(.image(
                        mediaType: "image/jpeg",
                        base64Data: jpegData.base64EncodedString()
                    ))
                }
                if !message.text.isEmpty {
                    blocks.append(.text(message.text))
                }
                if blocks.isEmpty {
                    blocks.append(.text(""))
                }
                return RequestMessage(role: "user", content: blocks)
            case .assistant:
                return RequestMessage(role: "assistant", content: [.text(message.text)])
            }
        }
    }

    private func resizeImage(_ image: UIImage) -> UIImage {
        let maxDim = Self.maxImageDimension
        let size = image.size
        guard size.width > maxDim || size.height > maxDim else { return image }

        let scale = min(maxDim / size.width, maxDim / size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
