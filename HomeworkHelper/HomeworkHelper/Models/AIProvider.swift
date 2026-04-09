import Foundation

enum AIProvider: String, CaseIterable, Identifiable {
    case anthropic = "Anthropic"
    case openAI = "OpenAI"
    case openRouter = "OpenRouter"
    case groq = "Free"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .anthropic:  return "brain"
        case .openAI:     return "sparkles"
        case .openRouter: return "arrow.triangle.branch"
        case .groq:       return "bolt.fill"
        }
    }

    var defaultModel: String {
        switch self {
        case .anthropic:  return "claude-haiku-4-5-20251001"
        case .openAI:     return "gpt-4o-mini"
        case .openRouter: return "meta-llama/llama-3.1-8b-instruct:free"
        case .groq:       return "llama-3.3-70b-versatile"
        }
    }

    var apiEndpoint: String {
        switch self {
        case .anthropic:  return "https://api.anthropic.com/v1/messages"
        case .openAI:     return "https://api.openai.com/v1/chat/completions"
        case .openRouter: return "https://openrouter.ai/api/v1/chat/completions"
        case .groq:       return "https://api.groq.com/openai/v1/chat/completions"
        }
    }

    /// Unique Keychain account string per provider
    var keychainAccount: String { "api-key-\(rawValue.lowercased())" }

    var apiKeyPlaceholder: String {
        switch self {
        case .anthropic:  return "sk-ant-..."
        case .openAI:     return "sk-..."
        case .openRouter: return "sk-or-..."
        case .groq:       return "gsk_..."
        }
    }

    var getKeyURLString: String {
        switch self {
        case .anthropic:  return "https://console.anthropic.com"
        case .openAI:     return "https://platform.openai.com/api-keys"
        case .openRouter: return "https://openrouter.ai/keys"
        case .groq:       return "https://console.groq.com"
        }
    }

    /// Human-readable note shown in Settings
    var pricingNote: String {
        switch self {
        case .anthropic:  return "Free tier available"
        case .openAI:     return "Pay-as-you-go"
        case .openRouter: return "Free & paid models available"
        case .groq:       return "Free tier — fast Llama model"
        }
    }

    var usesOpenAIFormat: Bool { self != .anthropic }
}
