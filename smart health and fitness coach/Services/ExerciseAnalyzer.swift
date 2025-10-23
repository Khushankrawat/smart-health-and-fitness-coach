//
//  ExerciseAnalyzer.swift
//  smart health and fitness coach
//
//  Created by Khushank Rawat on 23/10/25.
//

import Foundation
import CoreGraphics

protocol ExerciseAnalyzer {
    func analyzePose(_ pose: Pose) -> ExerciseAnalysis
    func getFormScore() -> Double
    func getFeedback() -> [String]
    func reset()
}

struct ExerciseAnalysis {
    let formScore: Double
    let feedback: [String]
    let isInCorrectPosition: Bool
    let repetitionCount: Int
}

class SquatAnalyzer: ExerciseAnalyzer {
    private var repetitions = 0
    private var isInDownPosition = false
    private var lastKneeAngle: Double?
    private var feedbackMessages: [String] = []
    
    func analyzePose(_ pose: Pose) -> ExerciseAnalysis {
        feedbackMessages.removeAll()
        
        // Analyze knee angles
        let leftKneeAngle = pose.angleBetweenLandmarks(PoseLandmark.leftHip, PoseLandmark.leftKnee, PoseLandmark.leftAnkle)
        let rightKneeAngle = pose.angleBetweenLandmarks(PoseLandmark.rightHip, PoseLandmark.rightKnee, PoseLandmark.rightAnkle)
        
        guard let leftAngle = leftKneeAngle, let rightAngle = rightKneeAngle else {
            return ExerciseAnalysis(formScore: 0, feedback: ["Unable to detect pose"], isInCorrectPosition: false, repetitionCount: repetitions)
        }
        
        let avgKneeAngle = (leftAngle + rightAngle) / 2
        
        // Check for proper squat depth (knees should bend to ~90 degrees)
        if avgKneeAngle < 90 {
            if !isInDownPosition {
                repetitions += 1
                isInDownPosition = true
            }
        } else {
            isInDownPosition = false
        }
        
        // Analyze form
        var formScore = 100.0
        
        // Check knee alignment
        let kneeDistance = pose.distanceBetweenLandmarks(PoseLandmark.leftKnee, PoseLandmark.rightKnee)
        if let distance = kneeDistance, distance > 50 {
            formScore -= 20
            feedbackMessages.append("Keep knees closer together")
        }
        
        // Check back alignment
        let leftBackAngle = pose.angleBetweenLandmarks(PoseLandmark.leftShoulder, PoseLandmark.leftHip, PoseLandmark.leftKnee)
        if let angle = leftBackAngle, angle < 160 {
            formScore -= 15
            feedbackMessages.append("Keep your back straighter")
        }
        
        // Check if knees are tracking over toes
        let leftKneeToAnkle = pose.distanceBetweenLandmarks(PoseLandmark.leftKnee, PoseLandmark.leftAnkle)
        if let distance = leftKneeToAnkle, distance > 30 {
            formScore -= 10
            feedbackMessages.append("Keep knees over your toes")
        }
        
        if feedbackMessages.isEmpty {
            feedbackMessages.append("Great form! Keep it up!")
        }
        
        return ExerciseAnalysis(
            formScore: max(0, formScore),
            feedback: feedbackMessages,
            isInCorrectPosition: avgKneeAngle < 100,
            repetitionCount: repetitions
        )
    }
    
    func getFormScore() -> Double {
        return 85.0 // Placeholder - would be calculated from recent poses
    }
    
    func getFeedback() -> [String] {
        return feedbackMessages
    }
    
    func reset() {
        repetitions = 0
        isInDownPosition = false
        lastKneeAngle = nil
        feedbackMessages.removeAll()
    }
}

class PushUpAnalyzer: ExerciseAnalyzer {
    private var repetitions = 0
    private var isInDownPosition = false
    private var feedbackMessages: [String] = []
    
    func analyzePose(_ pose: Pose) -> ExerciseAnalysis {
        feedbackMessages.removeAll()
        
        // Analyze elbow angles
        let leftElbowAngle = pose.angleBetweenLandmarks(PoseLandmark.leftShoulder, PoseLandmark.leftElbow, PoseLandmark.leftWrist)
        let rightElbowAngle = pose.angleBetweenLandmarks(PoseLandmark.rightShoulder, PoseLandmark.rightElbow, PoseLandmark.rightWrist)
        
        guard let leftAngle = leftElbowAngle, let rightAngle = rightElbowAngle else {
            return ExerciseAnalysis(formScore: 0, feedback: ["Unable to detect pose"], isInCorrectPosition: false, repetitionCount: repetitions)
        }
        
        let avgElbowAngle = (leftAngle + rightAngle) / 2
        
        // Check for proper push-up depth
        if avgElbowAngle < 90 {
            if !isInDownPosition {
                repetitions += 1
                isInDownPosition = true
            }
        } else {
            isInDownPosition = false
        }
        
        // Analyze form
        var formScore = 100.0
        
        // Check body alignment
        let shoulderHipAngle = pose.angleBetweenLandmarks(PoseLandmark.leftShoulder, PoseLandmark.leftHip, PoseLandmark.leftKnee)
        if let angle = shoulderHipAngle, angle < 170 {
            formScore -= 20
            feedbackMessages.append("Keep your body straight")
        }
        
        // Check hand placement
        let handDistance = pose.distanceBetweenLandmarks(PoseLandmark.leftWrist, PoseLandmark.rightWrist)
        if let distance = handDistance, distance < 40 || distance > 80 {
            formScore -= 15
            feedbackMessages.append("Adjust hand placement")
        }
        
        if feedbackMessages.isEmpty {
            feedbackMessages.append("Perfect push-up form!")
        }
        
        return ExerciseAnalysis(
            formScore: max(0, formScore),
            feedback: feedbackMessages,
            isInCorrectPosition: avgElbowAngle < 100,
            repetitionCount: repetitions
        )
    }
    
    func getFormScore() -> Double {
        return 90.0 // Placeholder
    }
    
    func getFeedback() -> [String] {
        return feedbackMessages
    }
    
    func reset() {
        repetitions = 0
        isInDownPosition = false
        feedbackMessages.removeAll()
    }
}

class LungeAnalyzer: ExerciseAnalyzer {
    private var repetitions = 0
    private var isInDownPosition = false
    private var feedbackMessages: [String] = []
    
    func analyzePose(_ pose: Pose) -> ExerciseAnalysis {
        feedbackMessages.removeAll()
        
        // Analyze knee angles for both legs
        let leftKneeAngle = pose.angleBetweenLandmarks(PoseLandmark.leftHip, PoseLandmark.leftKnee, PoseLandmark.leftAnkle)
        let rightKneeAngle = pose.angleBetweenLandmarks(PoseLandmark.rightHip, PoseLandmark.rightKnee, PoseLandmark.rightAnkle)
        
        guard let leftAngle = leftKneeAngle, let rightAngle = rightKneeAngle else {
            return ExerciseAnalysis(formScore: 0, feedback: ["Unable to detect pose"], isInCorrectPosition: false, repetitionCount: repetitions)
        }
        
        // Check for lunge depth (front knee should be around 90 degrees)
        let frontKneeAngle = min(leftAngle, rightAngle)
        
        if frontKneeAngle < 90 {
            if !isInDownPosition {
                repetitions += 1
                isInDownPosition = true
            }
        } else {
            isInDownPosition = false
        }
        
        // Analyze form
        var formScore = 100.0
        
        // Check knee alignment
        let kneeDistance = pose.distanceBetweenLandmarks(PoseLandmark.leftKnee, PoseLandmark.rightKnee)
        if let distance = kneeDistance, distance > 40 {
            formScore -= 15
            feedbackMessages.append("Keep knees aligned")
        }
        
        // Check torso alignment
        let torsoAngle = pose.angleBetweenLandmarks(PoseLandmark.leftShoulder, PoseLandmark.leftHip, PoseLandmark.leftKnee)
        if let angle = torsoAngle, angle < 160 {
            formScore -= 10
            feedbackMessages.append("Keep torso upright")
        }
        
        if feedbackMessages.isEmpty {
            feedbackMessages.append("Excellent lunge form!")
        }
        
        return ExerciseAnalysis(
            formScore: max(0, formScore),
            feedback: feedbackMessages,
            isInCorrectPosition: frontKneeAngle < 100,
            repetitionCount: repetitions
        )
    }
    
    func getFormScore() -> Double {
        return 87.0
    }
    
    func getFeedback() -> [String] {
        return feedbackMessages
    }
    
    func reset() {
        repetitions = 0
        isInDownPosition = false
        feedbackMessages.removeAll()
    }
}

