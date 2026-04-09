import UIKit

enum MessageRole: String, Codable {
    case user
    case assistant
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: MessageRole
    let text: String
    let image: UIImage?
    let timestamp: Date
    var isStreaming: Bool

    init(role: MessageRole, text: String, image: UIImage? = nil, isStreaming: Bool = false) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.image = image
        self.timestamp = Date()
        self.isStreaming = isStreaming
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}
