import Foundation

enum Subject: String, CaseIterable, Identifiable {
    case general = "General"
    case math = "Math"
    case physics = "Physics"
    case chemistry = "Chemistry"
    case biology = "Biology"
    case english = "English"
    case history = "History"
    case computerScience = "Computer Science"
    case economics = "Economics"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "questionmark.circle"
        case .math: return "function"
        case .physics: return "atom"
        case .chemistry: return "flask"
        case .biology: return "leaf"
        case .english: return "text.book.closed"
        case .history: return "clock"
        case .computerScience: return "laptopcomputer"
        case .economics: return "chart.line.uptrend.xyaxis"
        }
    }

    var systemPromptHint: String {
        switch self {
        case .general: return ""
        case .math: return "You are an expert mathematician. Show all algebraic steps clearly."
        case .physics: return "You are an expert physicist. Include relevant formulas and units."
        case .chemistry: return "You are an expert chemist. Show balanced equations and reaction mechanisms."
        case .biology: return "You are an expert biologist. Use correct scientific terminology."
        case .english: return "You are an expert English teacher. Focus on grammar, structure, and style."
        case .history: return "You are an expert historian. Provide historical context and significance."
        case .computerScience: return "You are an expert computer scientist. Include code examples where helpful."
        case .economics: return "You are an expert economist. Include relevant economic models and graphs descriptions."
        }
    }
}
