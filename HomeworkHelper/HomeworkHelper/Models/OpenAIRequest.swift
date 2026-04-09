import Foundation

// MARK: - Request

struct OpenAIChatRequest: Encodable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model, messages
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Encodable {
    let role: String
    let content: OpenAIMessageContent
}

/// Either a plain string (text-only) or an array of content blocks (text + image)
enum OpenAIMessageContent: Encodable {
    case text(String)
    case blocks([OpenAIContentBlock])

    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let str):
            var container = encoder.singleValueContainer()
            try container.encode(str)
        case .blocks(let blocks):
            var container = encoder.singleValueContainer()
            try container.encode(blocks)
        }
    }
}

enum OpenAIContentBlock: Encodable {
    case text(String)
    case imageURL(String) // full data URI: "data:image/jpeg;base64,..."

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let str):
            try container.encode("text", forKey: .type)
            try container.encode(str, forKey: .text)
        case .imageURL(let url):
            try container.encode("image_url", forKey: .type)
            var nested = container.nestedContainer(keyedBy: ImageURLKeys.self, forKey: .imageURL)
            try nested.encode(url, forKey: .url)
        }
    }

    enum CodingKeys: String, CodingKey { case type, text, imageURL = "image_url" }
    enum ImageURLKeys: String, CodingKey { case url }
}

// MARK: - Response

struct OpenAIChatResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
        struct Message: Decodable {
            let content: String?
        }
    }

    var textContent: String {
        choices.first?.message.content ?? ""
    }
}
