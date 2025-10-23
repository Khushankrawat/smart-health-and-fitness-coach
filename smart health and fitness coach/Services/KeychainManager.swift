//
//  KeychainManager.swift
//  smart health and fitness coach
//
//  Created by Khushank Rawat on 23/10/25.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = AppConfig.Security.keychainService
    
    private init() {}
    
    // MARK: - Generic Keychain Operations
    
    func save(_ data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        
        return nil
    }
    
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Convenience Methods
    
    func saveString(_ string: String, forKey key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data, forKey: key)
    }
    
    func loadString(forKey key: String) -> String? {
        guard let data = load(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Auth Token Management
    
    func saveAuthToken(_ token: String) -> Bool {
        return saveString(token, forKey: AppConfig.Security.tokenStorageKey)
    }
    
    func loadAuthToken() -> String? {
        return loadString(forKey: AppConfig.Security.tokenStorageKey)
    }
    
    func deleteAuthToken() -> Bool {
        return delete(forKey: AppConfig.Security.tokenStorageKey)
    }
    
    // MARK: - User Data Management
    
    func saveUserData(_ userData: Data) -> Bool {
        return save(userData, forKey: AppConfig.Security.userStorageKey)
    }
    
    func loadUserData() -> Data? {
        return load(forKey: AppConfig.Security.userStorageKey)
    }
    
    func deleteUserData() -> Bool {
        return delete(forKey: AppConfig.Security.userStorageKey)
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
