import Foundation

struct AnthropicResponse: Decodable {
    let id: String
    let content: [ResponseContentBlock]
    let stopReason: String?
    let usage: Usage

    enum CodingKeys: String, CodingKey {
        case id, content, usage
        case stopReason = "stop_reason"
    }

    var textContent: String {
        content.compactMap { $0.text }.joined()
    }
}

struct ResponseContentBlock: Decodable {
    let type: String
    let text: String?
}

struct Usage: Decodable {
    let inputTokens: Int
    let outputTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

struct AnthropicErrorResponse: Decodable {
    let type: String
    let error: ErrorDetail

    struct ErrorDetail: Decodable {
        let type: String
        let message: String
    }
}

enum AppError: LocalizedError {
    case invalidAPIKey
    case rateLimited
    case serverError(Int)
    case apiError(String)
    case noAPIKey
    case networkError(String)
    case imageEncodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your key in Settings."
        case .rateLimited:
            return "Rate limit exceeded. Please wait a moment and try again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .apiError(let message):
            return "API error: \(message)"
        case .noAPIKey:
            return "No API key configured. Please add your Anthropic API key in Settings."
        case .networkError(let message):
            return "Network error: \(message)"
        case .imageEncodingFailed:
            return "Failed to process the selected image. Please try another."
        }
    }
}
