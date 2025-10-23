//
//  PoseLandmark.swift
//  smart health and fitness coach
//
//  Created by Khushank Rawat on 23/10/25.
//

import Foundation
import CoreGraphics

struct PoseLandmark: Identifiable {
    let id = UUID()
    let name: String
    var position: CGPoint
    var confidence: Float
    
    init(name: String, position: CGPoint, confidence: Float) {
        self.name = name
        self.position = position
        self.confidence = confidence
    }
}

struct Pose {
    let landmarks: [PoseLandmark]
    let timestamp: Date
    
    func landmark(named name: String) -> PoseLandmark? {
        return landmarks.first { $0.name == name }
    }
    
    func angleBetweenLandmarks(_ landmark1: String, _ landmark2: String, _ landmark3: String) -> Double? {
        guard let p1 = landmark(named: landmark1),
              let p2 = landmark(named: landmark2),
              let p3 = landmark(named: landmark3) else { return nil }
        
        let a = CGPoint(x: p1.position.x - p2.position.x, y: p1.position.y - p2.position.y)
        let b = CGPoint(x: p3.position.x - p2.position.x, y: p3.position.y - p2.position.y)
        
        let dot = a.x * b.x + a.y * b.y
        let magA = sqrt(a.x * a.x + a.y * a.y)
        let magB = sqrt(b.x * b.x + b.y * b.y)
        
        guard magA > 0 && magB > 0 else { return nil }
        
        let cosAngle = dot / (magA * magB)
        let angle = acos(max(-1, min(1, cosAngle)))
        return angle * 180 / Double.pi
    }
    
    func distanceBetweenLandmarks(_ landmark1: String, _ landmark2: String) -> Double? {
        guard let p1 = landmark(named: landmark1),
              let p2 = landmark(named: landmark2) else { return nil }
        
        let dx = p1.position.x - p2.position.x
        let dy = p1.position.y - p2.position.y
        return sqrt(dx * dx + dy * dy)
    }
}

// PoseNet landmark names
extension PoseLandmark {
    static let nose = "nose"
    static let leftEye = "left_eye"
    static let rightEye = "right_eye"
    static let leftEar = "left_ear"
    static let rightEar = "right_ear"
    static let leftShoulder = "left_shoulder"
    static let rightShoulder = "right_shoulder"
    static let leftElbow = "left_elbow"
    static let rightElbow = "right_elbow"
    static let leftWrist = "left_wrist"
    static let rightWrist = "right_wrist"
    static let leftHip = "left_hip"
    static let rightHip = "right_hip"
    static let leftKnee = "left_knee"
    static let rightKnee = "right_knee"
    static let leftAnkle = "left_ankle"
    static let rightAnkle = "right_ankle"
}

