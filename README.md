# Smart Health and Fitness Coach

An AI-powered iOS app that uses computer vision to analyze exercise form in real-time and provides corrective feedback.

## Features

- **Real-time Pose Detection**: Uses Core ML with pose estimation models to track body movements
- **Exercise Analysis**: Supports squats, push-ups, yoga poses, planks, and lunges
- **Form Feedback**: Provides real-time feedback on exercise form and technique
- **Progress Tracking**: Stores workout history and tracks improvement over time
- **Beautiful UI**: Modern SwiftUI interface with intuitive navigation
- **Cloud Sync**: Backend integration for data synchronization and advanced analytics

## Tech Stack

### Frontend
- **SwiftUI**: Modern iOS UI framework
- **AVFoundation**: Camera and video processing
- **Core ML**: On-device machine learning for pose detection
- **Core Data**: Local data persistence

### Backend (Optional)
- **Node.js**: Server runtime
- **Express.js**: Web framework
- **MongoDB**: Database for flexible data storage
- **REST API**: Communication between app and server

## Project Structure

```
smart health and fitness coach/
├── Models/
│   ├── ExerciseType.swift          # Exercise definitions and types
│   └── PoseLandmark.swift          # Pose detection data structures
├── Views/
│   └── CameraView.swift            # Camera interface and pose overlay
├── Services/
│   ├── ExerciseAnalyzer.swift      # Exercise form analysis logic
│   ├── WorkoutDataManager.swift    # Core Data management
│   └── BackendService.swift        # API communication
├── ContentView.swift               # Main app interface
└── WorkoutModel.xcdatamodeld/     # Core Data model
```

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Device with front-facing camera (for testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart-health-and-fitness-coach
   ```

2. **Open in Xcode**
   ```bash
   open "smart health and fitness coach.xcodeproj"
   ```

3. **Configure Camera Permissions**
   - Add camera usage description to `Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access to analyze your exercise form</string>
   ```

4. **Add Core ML Model** (Optional)
   - Download PoseNet or MoveNet model from Apple's ML models
   - Add to project bundle
   - Update pose detection logic in `CameraView.swift`

### Running the App

1. Select your target device or simulator
2. Build and run the project (⌘+R)
3. Grant camera permissions when prompted
4. Select an exercise and start your workout!

## Core ML Integration

To integrate real pose detection:

1. **Download PoseNet Model**
   - Visit Apple's Core ML models page
   - Download PoseNet model
   - Add to Xcode project

2. **Update Pose Detection**
   ```swift
   import CoreML
   import Vision
   
   // Replace mock pose creation with real ML inference
   func detectPose(from sampleBuffer: CMSampleBuffer) -> Pose? {
       // Implement Core ML pose detection
   }
   ```

## Backend Setup (Optional)

### Node.js Backend

1. **Initialize Node.js project**
   ```bash
   mkdir fitness-coach-backend
   cd fitness-coach-backend
   npm init -y
   ```

2. **Install dependencies**
   ```bash
   npm install express mongoose cors dotenv bcryptjs jsonwebtoken
   ```

3. **Create server structure**
   ```
   backend/
   ├── server.js
   ├── models/
   │   └── Workout.js
   ├── routes/
   │   ├── auth.js
   │   └── workouts.js
   └── middleware/
       └── auth.js
   ```

4. **Update BackendService.swift**
   - Replace `baseURL` with your actual server URL
   - Configure authentication tokens

## Exercise Analysis

The app analyzes various aspects of exercise form:

### Squats
- Knee angle tracking (90-degree target)
- Knee alignment over toes
- Back posture maintenance
- Repetition counting

### Push-ups
- Elbow angle analysis
- Body alignment
- Hand placement verification
- Depth tracking

### Yoga Poses
- Pose recognition
- Alignment feedback
- Balance assessment
- Duration tracking

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Future Enhancements

- [ ] Additional exercise types (deadlifts, pull-ups, etc.)
- [ ] Social features and challenges
- [ ] Integration with Apple Health
- [ ] Advanced analytics and insights
- [ ] Custom workout plans
- [ ] Voice coaching and cues
- [ ] Multi-user support

## Acknowledgments

- Apple's Core ML and PoseNet models
- SwiftUI and AVFoundation frameworks
- The fitness and computer vision communities

