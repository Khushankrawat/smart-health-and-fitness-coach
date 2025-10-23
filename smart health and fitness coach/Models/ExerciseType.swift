//
//  ExerciseType.swift
//  smart health and fitness coach
//
//  Created by Khushank Rawat on 23/10/25.
//

import Foundation

enum ExerciseType: String, CaseIterable, Identifiable, Codable {
    case squat = "Squat"
    case pushUp = "Push Up"
    case lunges = "Lunges"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .squat: return "Squats"
        case .pushUp: return "Push-ups"
        case .lunges: return "Lunges"
        }
    }
    
    var description: String {
        switch self {
        case .squat: return "Perfect your squat form with real-time feedback"
        case .pushUp: return "Master push-up technique with AI guidance"
        case .lunges: return "Execute perfect lunges with form correction"
        }
    }
    
    var icon: String {
        switch self {
        case .squat: return "figure.strengthtraining.traditional"
        case .pushUp: return "figure.strengthtraining.functional"
        case .lunges: return "figure.walk"
        }
    }
}

struct ExerciseSession: Identifiable, Codable {
    let id = UUID()
    let exerciseType: ExerciseType
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
    var repetitions: Int = 0
    var formScore: Double = 0.0
    var feedback: [String] = []
    
    var isCompleted: Bool {
        endTime != nil
    }
}

