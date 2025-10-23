//
//  WorkoutDataManager.swift
//  smart health and fitness coach
//
//  Created by Khushank Rawat on 23/10/25.
//

import Foundation
import CoreData
import SwiftUI

class WorkoutDataManager: ObservableObject {
    static let shared = WorkoutDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WorkoutModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    func saveWorkoutSession(_ session: ExerciseSession) {
        let workout = WorkoutEntity(context: context)
        workout.id = session.id
        workout.exerciseType = session.exerciseType.rawValue
        workout.startTime = session.startTime
        workout.endTime = session.endTime
        workout.duration = session.duration
        workout.repetitions = Int32(session.repetitions)
        workout.formScore = session.formScore
        workout.feedback = session.feedback.joined(separator: "|")
        
        save()
    }
    
    func fetchWorkoutSessions() -> [ExerciseSession] {
        let request: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutEntity.startTime, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let exerciseType = ExerciseType(rawValue: entity.exerciseType ?? ""),
                      let startTime = entity.startTime else { return nil }
                
                return ExerciseSession(
                    exerciseType: exerciseType,
                    startTime: startTime,
                    endTime: entity.endTime,
                    repetitions: Int(entity.repetitions),
                    formScore: entity.formScore,
                    feedback: entity.feedback?.components(separatedBy: "|") ?? []
                )
            }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
}


