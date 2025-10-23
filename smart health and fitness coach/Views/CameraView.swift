//
//  CameraView.swift
//  smart health and fitness coach
//
//  Created by Khushank Rawat on 23/10/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraView: UIViewRepresentable {
    @Binding var isSessionRunning: Bool
    let onFrameCaptured: (CMSampleBuffer) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black
        
        let previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.backgroundColor = UIColor.black.cgColor
        view.layer.addSublayer(previewLayer)
        
        context.coordinator.previewLayer = previewLayer
        
        print("CameraView: Preview layer created and added to view")
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview layer frame if needed
        if let previewLayer = context.coordinator.previewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let parent: CameraView
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        init(_ parent: CameraView) {
            self.parent = parent
            super.init()
            setupCamera()
        }
        
        private func setupCamera() {
            // Check camera authorization status
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            print("CameraView: Authorization status: \(status.rawValue)")
            
            switch status {
            case .authorized:
                print("CameraView: Camera access authorized, setting up session")
                setupCaptureSession()
            case .notDetermined:
                print("CameraView: Camera access not determined, requesting permission")
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            print("CameraView: Permission granted, setting up session")
                            self.setupCaptureSession()
                        } else {
                            print("CameraView: Permission denied")
                        }
                    }
                }
            case .denied, .restricted:
                print("CameraView: Camera access denied or restricted")
            @unknown default:
                print("CameraView: Unknown camera authorization status")
            }
        }
        
        private func setupCaptureSession() {
            print("CameraView: Setting up capture session")
            let session = AVCaptureSession()
            session.sessionPreset = .high
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                print("CameraView: Unable to access front camera")
                return
            }
            
            print("CameraView: Found front camera: \(camera.localizedName)")
            
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if session.canAddInput(input) {
                    session.addInput(input)
                    print("CameraView: Added camera input to session")
                } else {
                    print("CameraView: Cannot add camera input to session")
                }
                
                let output = AVCaptureVideoDataOutput()
                output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                if session.canAddOutput(output) {
                    session.addOutput(output)
                    print("CameraView: Added video output to session")
                } else {
                    print("CameraView: Cannot add video output to session")
                }
                
                self.captureSession = session
                
                // Connect the preview layer to the session
                DispatchQueue.main.async {
                    if let previewLayer = self.previewLayer {
                        previewLayer.session = session
                        print("CameraView: Connected preview layer to session")
                    } else {
                        print("CameraView: Preview layer is nil, cannot connect to session")
                    }
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    print("CameraView: Starting capture session")
                    session.startRunning()
                    DispatchQueue.main.async {
                        self.parent.isSessionRunning = true
                        print("CameraView: Capture session started, isSessionRunning = true")
                    }
                }
                
            } catch {
                print("CameraView: Error setting up camera: \(error)")
            }
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            parent.onFrameCaptured(sampleBuffer)
        }
        
        deinit {
            captureSession?.stopRunning()
        }
    }
}

struct CameraViewWrapper: View {
    @State private var isSessionRunning = false
    @State private var currentPose: Pose?
    @State private var exerciseAnalyzer: ExerciseAnalyzer?
    @State private var selectedExercise: ExerciseType = .squat
    @State private var mockSquatPhase: Double = 0.0 // 0.0 = standing, 1.0 = squatting
    @State private var mockPushUpPhase: Double = 0.0 // 0.0 = up, 1.0 = down
    @State private var mockLungePhase: Double = 0.0 // 0.0 = standing, 1.0 = lunging
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            CameraView(isSessionRunning: $isSessionRunning) { sampleBuffer in
                // Process frame for pose detection
                processFrame(sampleBuffer)
            }
            
            // Overlay UI
            VStack {
                // Close button and status
                HStack {
                    // Camera status indicator
                    HStack {
                        Circle()
                            .fill(isSessionRunning ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        Text(isSessionRunning ? "Camera Active" : "Camera Inactive")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                
                Spacer()
                
                // Exercise selection
                HStack {
                    ForEach(ExerciseType.allCases) { exercise in
                        Button(action: {
                            selectedExercise = exercise
                            setupAnalyzer()
                        }) {
                            VStack {
                                Image(systemName: exercise.icon)
                                    .font(.title2)
                                Text(exercise.displayName)
                                    .font(.caption)
                            }
                            .foregroundColor(selectedExercise == exercise ? .white : .gray)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedExercise == exercise ? Color.blue : Color.clear)
                            )
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.7))
                )
                .padding()
                
                // Feedback display
                if let analysis = currentAnalysis {
                    VStack {
                        Text("Form Score: \(Int(analysis.formScore))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Reps: \(analysis.repetitionCount)")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        ForEach(analysis.feedback, id: \.self) { message in
                            Text(message)
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.7))
                    )
                    .padding()
                }
            }
        }
        .onAppear {
            setupAnalyzer()
        }
    }
    
    @State private var currentAnalysis: ExerciseAnalysis?
    
    private func setupAnalyzer() {
        // Reset animation phases when switching exercises
        mockSquatPhase = 0.0
        mockPushUpPhase = 0.0
        mockLungePhase = 0.0
        
        switch selectedExercise {
        case .squat:
            exerciseAnalyzer = SquatAnalyzer()
        case .pushUp:
            exerciseAnalyzer = PushUpAnalyzer()
        case .lunges:
            exerciseAnalyzer = LungeAnalyzer()
        }
    }
    
    private func processFrame(_ sampleBuffer: CMSampleBuffer) {
        // This is where we would integrate with Core ML for pose detection
        // For now, we'll simulate pose detection
        DispatchQueue.main.async {
            // Animate the mock poses to simulate movement
            animateMockPoses()
            
            // Simulate pose analysis
            if let analyzer = exerciseAnalyzer {
                // Create a mock pose for demonstration
                let mockPose = createMockPose()
                let analysis = analyzer.analyzePose(mockPose)
                currentAnalysis = analysis
            }
        }
    }
    
    private func animateMockPoses() {
        // Animate poses based on selected exercise
        switch selectedExercise {
        case .squat:
            // Cycle through squat movement (standing -> squatting -> standing)
            mockSquatPhase += 0.02 // Adjust speed as needed
            if mockSquatPhase > 2.0 {
                mockSquatPhase = 0.0
            }
        case .pushUp:
            // Cycle through push-up movement (up -> down -> up)
            mockPushUpPhase += 0.02 // Adjust speed as needed
            if mockPushUpPhase > 2.0 {
                mockPushUpPhase = 0.0
            }
        case .lunges:
            // Cycle through lunge movement (standing -> lunging -> standing)
            mockLungePhase += 0.02
            if mockLungePhase > 2.0 {
                mockLungePhase = 0.0
            }
        }
    }
    
    private func createMockPose() -> Pose {
        // Create dynamic mock landmarks based on exercise type and phase
        let landmarks: [PoseLandmark]
        
        switch selectedExercise {
        case .squat:
            landmarks = createSquatPose(phase: mockSquatPhase)
        case .pushUp:
            landmarks = createPushUpPose(phase: mockPushUpPhase)
        case .lunges:
            landmarks = createLungePose(phase: mockLungePhase)
        }
        
        return Pose(landmarks: landmarks, timestamp: Date())
    }
    
    private func createSquatPose(phase: Double) -> [PoseLandmark] {
        // Calculate knee angle based on phase
        // Phase 0.0-1.0: going down (knee angle decreases)
        // Phase 1.0-2.0: going up (knee angle increases)
        let normalizedPhase = phase.truncatingRemainder(dividingBy: 2.0)
        let kneeAngle: Double
        
        if normalizedPhase <= 1.0 {
            // Going down: knee angle from 180 to 60 degrees
            kneeAngle = 180 - (normalizedPhase * 120)
        } else {
            // Going up: knee angle from 60 to 180 degrees
            kneeAngle = 60 + ((normalizedPhase - 1.0) * 120)
        }
        
        // Convert knee angle to landmark positions
        let hipY: CGFloat = 300
        let kneeY: CGFloat = hipY + CGFloat(100 * sin(kneeAngle * .pi / 180))
        let ankleY: CGFloat = kneeY + CGFloat(100 * sin(kneeAngle * .pi / 180))
        
        return [
            PoseLandmark(name: PoseLandmark.leftShoulder, position: CGPoint(x: 100, y: 150), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.rightShoulder, position: CGPoint(x: 200, y: 150), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.leftElbow, position: CGPoint(x: 120, y: 200), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.rightElbow, position: CGPoint(x: 180, y: 200), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.leftWrist, position: CGPoint(x: 130, y: 250), confidence: 0.7),
            PoseLandmark(name: PoseLandmark.rightWrist, position: CGPoint(x: 170, y: 250), confidence: 0.7),
            PoseLandmark(name: PoseLandmark.leftHip, position: CGPoint(x: 140, y: hipY), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.rightHip, position: CGPoint(x: 160, y: hipY), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.leftKnee, position: CGPoint(x: 145, y: kneeY), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.rightKnee, position: CGPoint(x: 155, y: kneeY), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.leftAnkle, position: CGPoint(x: 150, y: ankleY), confidence: 0.7),
            PoseLandmark(name: PoseLandmark.rightAnkle, position: CGPoint(x: 150, y: ankleY), confidence: 0.7)
        ]
    }
    
    private func createPushUpPose(phase: Double) -> [PoseLandmark] {
        // Calculate elbow angle based on phase
        // Phase 0.0-1.0: going down (elbow angle decreases)
        // Phase 1.0-2.0: going up (elbow angle increases)
        let normalizedPhase = phase.truncatingRemainder(dividingBy: 2.0)
        let elbowAngle: Double
        
        if normalizedPhase <= 1.0 {
            // Going down: elbow angle from 180 to 60 degrees
            elbowAngle = 180 - (normalizedPhase * 120)
        } else {
            // Going up: elbow angle from 60 to 180 degrees
            elbowAngle = 60 + ((normalizedPhase - 1.0) * 120)
        }
        
        // Convert elbow angle to landmark positions
        let shoulderY: CGFloat = 150
        let elbowY: CGFloat = shoulderY + CGFloat(50 * sin(elbowAngle * .pi / 180))
        let wristY: CGFloat = elbowY + CGFloat(50 * sin(elbowAngle * .pi / 180))
        
        return [
            PoseLandmark(name: PoseLandmark.leftShoulder, position: CGPoint(x: 100, y: shoulderY), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.rightShoulder, position: CGPoint(x: 200, y: shoulderY), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.leftElbow, position: CGPoint(x: 120, y: elbowY), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.rightElbow, position: CGPoint(x: 180, y: elbowY), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.leftWrist, position: CGPoint(x: 130, y: wristY), confidence: 0.7),
            PoseLandmark(name: PoseLandmark.rightWrist, position: CGPoint(x: 170, y: wristY), confidence: 0.7),
            PoseLandmark(name: PoseLandmark.leftHip, position: CGPoint(x: 140, y: 300), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.rightHip, position: CGPoint(x: 160, y: 300), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.leftKnee, position: CGPoint(x: 145, y: 400), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.rightKnee, position: CGPoint(x: 155, y: 400), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.leftAnkle, position: CGPoint(x: 150, y: 500), confidence: 0.7),
            PoseLandmark(name: PoseLandmark.rightAnkle, position: CGPoint(x: 150, y: 500), confidence: 0.7)
        ]
    }
    
    private func createLungePose(phase: Double) -> [PoseLandmark] {
        // Calculate lunge depth based on phase
        // Phase 0.0-1.0: going down (front knee angle decreases)
        // Phase 1.0-2.0: going up (front knee angle increases)
        let normalizedPhase = phase.truncatingRemainder(dividingBy: 2.0)
        let frontKneeAngle: Double
        
        if normalizedPhase <= 1.0 {
            // Going down: front knee angle from 180 to 60 degrees
            frontKneeAngle = 180 - (normalizedPhase * 120)
        } else {
            // Going up: front knee angle from 60 to 180 degrees
            frontKneeAngle = 60 + ((normalizedPhase - 1.0) * 120)
        }
        
        // Convert knee angle to landmark positions
        let hipY: CGFloat = 300
        let leftKneeY: CGFloat = hipY + CGFloat(80 * sin(frontKneeAngle * Double.pi / 180))
        let rightKneeY: CGFloat = hipY + CGFloat(80 * sin(180 * Double.pi / 180)) // Back leg stays straight
        
        return [
            PoseLandmark(name: PoseLandmark.leftShoulder, position: CGPoint(x: 100, y: 150), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.rightShoulder, position: CGPoint(x: 200, y: 150), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.leftElbow, position: CGPoint(x: 120, y: 200), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.rightElbow, position: CGPoint(x: 180, y: 200), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.leftWrist, position: CGPoint(x: 130, y: 250), confidence: 0.7),
            PoseLandmark(name: PoseLandmark.rightWrist, position: CGPoint(x: 170, y: 250), confidence: 0.7),
            PoseLandmark(name: PoseLandmark.leftHip, position: CGPoint(x: 140, y: hipY), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.rightHip, position: CGPoint(x: 160, y: hipY), confidence: 0.9),
            PoseLandmark(name: PoseLandmark.leftKnee, position: CGPoint(x: 145, y: leftKneeY), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.rightKnee, position: CGPoint(x: 155, y: rightKneeY), confidence: 0.8),
            PoseLandmark(name: PoseLandmark.leftAnkle, position: CGPoint(x: 150, y: 500), confidence: 0.7),
            PoseLandmark(name: PoseLandmark.rightAnkle, position: CGPoint(x: 150, y: 500), confidence: 0.7)
        ]
    }
}

