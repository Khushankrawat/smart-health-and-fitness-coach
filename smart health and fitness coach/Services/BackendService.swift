//
//  BackendService.swift
//  smart health and fitness coach
//
//  Created by Khushank Rawat on 23/10/25.
//

import Foundation
import Combine

class BackendService: ObservableObject {
    static let shared = BackendService()
    
    private let baseURL = AppConfig.API.baseURL
    private var cancellables = Set<AnyCancellable>()
    private let keychainManager = KeychainManager.shared
    
    private init() {}
    
    // MARK: - User Authentication
    
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        let loginRequest = LoginRequest(email: email, password: password)
        
        return performRequest(
            endpoint: "/auth/login",
            method: .POST,
            body: loginRequest
        )
    }
    
    func register(email: String, password: String, name: String) -> AnyPublisher<AuthResponse, Error> {
        let registerRequest = RegisterRequest(email: email, password: password, name: name)
        
        return performRequest(
            endpoint: "/auth/register",
            method: .POST,
            body: registerRequest
        )
    }
    
    // MARK: - Workout Data Sync
    
    func syncWorkoutSession(_ session: ExerciseSession) -> AnyPublisher<SyncResponse, Error> {
        let workoutRequest = WorkoutRequest(
            id: session.id.uuidString,
            exerciseType: session.exerciseType.rawValue,
            startTime: session.startTime,
            endTime: session.endTime,
            duration: session.duration,
            repetitions: session.repetitions,
            formScore: session.formScore,
            feedback: session.feedback
        )
        
        return performRequest(
            endpoint: "/workouts",
            method: .POST,
            body: workoutRequest
        )
    }
    
    func fetchWorkoutHistory() -> AnyPublisher<[ExerciseSession], Error> {
        return performRequest(
            endpoint: "/workouts",
            method: .GET,
            body: nil as EmptyBody?
        )
    }
    
    // MARK: - Analytics
    
    func getWorkoutAnalytics() -> AnyPublisher<WorkoutAnalytics, Error> {
        return performRequest(
            endpoint: "/analytics/workouts",
            method: .GET,
            body: nil as EmptyBody?
        )
    }
    
    // MARK: - Authentication Token Management
    
    func saveAuthToken(_ token: String) -> Bool {
        return keychainManager.saveAuthToken(token)
    }
    
    func loadAuthToken() -> String? {
        return keychainManager.loadAuthToken()
    }
    
    func deleteAuthToken() -> Bool {
        return keychainManager.deleteAuthToken()
    }
    
    func isAuthenticated() -> Bool {
        return loadAuthToken() != nil
    }
    
    func logout() -> Bool {
        return deleteAuthToken()
    }
    
    // MARK: - Generic Request Handler
    
    private func performRequest<T: Codable, R: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: T? = nil
    ) -> AnyPublisher<R, Error> {
        
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: BackendError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication token if available (using secure keychain storage)
        if let token = keychainManager.loadAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: R.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Request/Response Models

struct EmptyBody: Codable {}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct User: Codable {
    let id: String
    let email: String
    let name: String
}

struct WorkoutRequest: Codable {
    let id: String
    let exerciseType: String
    let startTime: Date
    let endTime: Date?
    let duration: TimeInterval
    let repetitions: Int
    let formScore: Double
    let feedback: [String]
}

struct SyncResponse: Codable {
    let success: Bool
    let message: String
}

struct WorkoutAnalytics: Codable {
    let totalWorkouts: Int
    let totalRepetitions: Int
    let averageFormScore: Double
    let weeklyProgress: [WeeklyProgress]
    let exerciseBreakdown: [ExerciseBreakdown]
}

struct WeeklyProgress: Codable {
    let week: String
    let workouts: Int
    let averageScore: Double
}

struct ExerciseBreakdown: Codable {
    let exerciseType: String
    let count: Int
    let averageScore: Double
}

// MARK: - HTTP Methods

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Errors

enum BackendError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
}

