//
//  AppConfig.swift
//  smart health and fitness coach
//
//  Created by Khushank Rawat on 23/10/25.
//

import Foundation

struct AppConfig {
    
    // MARK: - API Configuration
    struct API {
        static let baseURL: String = {
            // Check for environment variable first
            if let url = ProcessInfo.processInfo.environment["BACKEND_URL"] {
                return url
            }
            
            // Check Info.plist for configuration
            if let url = Bundle.main.object(forInfoDictionaryKey: "BackendURL") as? String {
                return url
            }
            
            // Fallback to placeholder (should be replaced in production)
            return "https://your-backend-api.com/api"
        }()
        
        static let timeout: TimeInterval = 30.0
        static let maxRetries: Int = 3
    }
    
    // MARK: - Security Configuration
    struct Security {
        static let tokenStorageKey = "auth_token"
        static let userStorageKey = "user_data"
        
        // Keychain service identifier
        static let keychainService = "com.yourcompany.smart-health-and-fitness-coach"
        
        // Token expiration check interval
        static let tokenCheckInterval: TimeInterval = 300 // 5 minutes
    }
    
    // MARK: - Camera Configuration
    struct Camera {
        static let sessionPreset = "high"
        static let frameRate: Int32 = 30
        static let maxResolution = CGSize(width: 1920, height: 1080)
    }
    
    // MARK: - Exercise Configuration
    struct Exercise {
        static let defaultRepetitions = 0
        static let defaultFormScore = 0.0
        static let maxFeedbackItems = 5
    }
    
    // MARK: - Debug Configuration
    struct Debug {
        static let isDebugMode: Bool = {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }()
        
        static let enableLogging: Bool = isDebugMode
        static let enableMockData: Bool = isDebugMode
    }
}

// MARK: - Environment Detection
extension AppConfig {
    static var isProduction: Bool {
        return !Debug.isDebugMode
    }
    
    static var isDevelopment: Bool {
        return Debug.isDebugMode
    }
}
