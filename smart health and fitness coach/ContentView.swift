//
//  ContentView.swift
//  smart health and fitness coach
//
//  Created by Khushank Rawat on 23/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingCamera = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView(showingCamera: $showingCamera)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Exercise Library Tab
            ExerciseLibraryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Exercises")
                }
                .tag(1)
            
            // Progress Tab
            ProgressView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
                .tag(2)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .fullScreenCover(isPresented: $showingCamera) {
            CameraViewWrapper()
        }
    }
}

struct HomeView: View {
    @Binding var showingCamera: Bool
    @State private var selectedExercise: ExerciseType = .squat
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Welcome to Smart Coach")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Your AI-powered fitness companion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Quick Start Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Start")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Select an exercise to begin your AI-guided workout")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(ExerciseType.allCases.prefix(4)) { exercise in
                                ExerciseCard(
                                    exercise: exercise,
                                    isSelected: selectedExercise == exercise
                                ) {
                                    selectedExercise = exercise
                                }
                            }
                        }
                    }
                    .padding()
                    
                    // Start Workout Button
                    Button(action: {
                        showingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Start \(selectedExercise.displayName) Workout")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                    }
                    .padding()
                    
                    // Recent Workouts
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Workouts")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        // Placeholder for recent workouts
                        VStack(spacing: 10) {
                            ForEach(0..<3) { _ in
                                HStack {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Squat Session")
                                            .font(.headline)
                                        Text("Yesterday • 15 reps • 85% form")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Smart Coach")
        }
    }
}

struct ExerciseCard: View {
    let exercise: ExerciseType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Image(systemName: exercise.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(exercise.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(exercise.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExerciseLibraryView: View {
    var body: some View {
        NavigationView {
            List(ExerciseType.allCases) { exercise in
                HStack {
                    Image(systemName: exercise.icon)
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading) {
                        Text(exercise.displayName)
                            .font(.headline)
                        Text(exercise.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Exercise Library")
        }
    }
}

struct ProgressView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Progress tracking coming soon!")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Progress")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings coming soon!")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
