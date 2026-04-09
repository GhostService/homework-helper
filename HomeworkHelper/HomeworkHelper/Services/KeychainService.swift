import Foundation
import Security

struct KeychainService {
    private static let service = "com.homeworkhelper.app"

    // MARK: - Per-provider API keys

    static func saveAPIKey(_ key: String, for provider: AIProvider) throws {
        try save(key, account: provider.keychainAccount)
    }

    static func loadAPIKey(for provider: AIProvider) -> String? {
        load(account: provider.keychainAccount)
    }

    static func deleteAPIKey(for provider: AIProvider) throws {
        try delete(account: provider.keychainAccount)
    }

    static func hasAPIKey(for provider: AIProvider) -> Bool {
        loadAPIKey(for: provider) != nil
    }

    // MARK: - Generic helpers

    private static func save(_ value: String, account: String) throws {
        guard let data = value.data(using: .utf8) else { return }
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        let attributes: [CFString: Any] = [
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecItemNotFound {
            var addQuery = query
            attributes.forEach { addQuery[$0.key] = $0.value }
            let s = SecItemAdd(addQuery as CFDictionary, nil)
            guard s == errSecSuccess else { throw KeychainError.unhandledError(s) }
        } else if status == errSecSuccess {
            let s = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            guard s == errSecSuccess else { throw KeychainError.unhandledError(s) }
        } else {
            throw KeychainError.unhandledError(status)
        }
    }

    private static func load(account: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func delete(account: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status)
        }
    }

    // MARK: - Error

    enum KeychainError: LocalizedError {
        case unhandledError(OSStatus)
        var errorDescription: String? {
            if case .unhandledError(let s) = self { return "Keychain error: \(s)" }
            return nil
        }
    }
}
