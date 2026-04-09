import Foundation

struct AnthropicRequest: Encodable {
    let model: String
    let maxTokens: Int
    let system: String
    let messages: [RequestMessage]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system
        case messages
    }
}

struct RequestMessage: Encodable {
    let role: String
    let content: [ContentBlock]
}

enum ContentBlock {
    case text(String)
    case image(mediaType: String, base64Data: String)
}

extension ContentBlock: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let mediaType, let base64Data):
            try container.encode("image", forKey: .type)
            var sourceContainer = container.nestedContainer(keyedBy: SourceCodingKeys.self, forKey: .source)
            try sourceContainer.encode("base64", forKey: .type)
            try sourceContainer.encode(mediaType, forKey: .mediaType)
            try sourceContainer.encode(base64Data, forKey: .data)
        }
    }

    enum CodingKeys: String, CodingKey {
        case type, text, source
    }

    enum SourceCodingKeys: String, CodingKey {
        case type
        case mediaType = "media_type"
        case data
    }
}
