import Foundation

enum AIProvider: String, CaseIterable, Identifiable {
    case free = "Free"
    case anthropic = "Anthropic"
    case openAI = "OpenAI"
    case openRouter = "OpenRouter"

    var id: String { rawValue }

    /// Whether this provider needs an API key stored in Keychain
    var requiresAPIKey: Bool {
        switch self {
        case .free:       return false
        case .anthropic, .openAI, .openRouter: return true
        }
    }

    var icon: String {
        switch self {
        case .free:       return "bolt.fill"
        case .anthropic:  return "brain"
        case .openAI:     return "sparkles"
        case .openRouter: return "arrow.triangle.branch"
        }
    }

    var defaultModel: String {
        switch self {
        case .free:       return "openai"          // Pollinations routes to GPT-4o mini
        case .anthropic:  return "claude-haiku-4-5-20251001"
        case .openAI:     return "gpt-4o-mini"
        case .openRouter: return "meta-llama/llama-3.1-8b-instruct:free"
        }
    }

    var apiEndpoint: String {
        switch self {
        case .free:       return "https://text.pollinations.ai/openai"
        case .anthropic:  return "https://api.anthropic.com/v1/messages"
        case .openAI:     return "https://api.openai.com/v1/chat/completions"
        case .openRouter: return "https://openrouter.ai/api/v1/chat/completions"
        }
    }

    /// Unique Keychain account string per provider (unused for .free)
    var keychainAccount: String { "api-key-\(rawValue.lowercased())" }

    var apiKeyPlaceholder: String {
        switch self {
        case .free:       return ""
        case .anthropic:  return "sk-ant-..."
        case .openAI:     return "sk-..."
        case .openRouter: return "sk-or-..."
        }
    }

    var getKeyURLString: String {
        switch self {
        case .free:       return ""
        case .anthropic:  return "https://console.anthropic.com"
        case .openAI:     return "https://platform.openai.com/api-keys"
        case .openRouter: return "https://openrouter.ai/keys"
        }
    }

    var pricingNote: String {
        switch self {
        case .free:       return "No account needed — powered by Pollinations.ai"
        case .anthropic:  return "Free tier available at console.anthropic.com"
        case .openAI:     return "Pay-as-you-go at platform.openai.com"
        case .openRouter: return "Free & paid models at openrouter.ai"
        }
    }

    var usesOpenAIFormat: Bool { self != .anthropic }
}
