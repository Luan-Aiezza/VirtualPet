import Foundation
import HealthKit
import Combine

/// A centralized Health manager for Sleep and Workout data.
class HealthManager: ObservableObject {
    static let shared = HealthManager()
    
    let healthStore = HKHealthStore()
    
    @Published var isSleepAuthorized = false
    @Published var isWorkoutAuthorized = false
    
    /// Call this on app launch or when you need HealthKit access.
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let workoutType = HKObjectType.workoutType()
        let typesToRead: Set<HKObjectType> = [sleepType, workoutType]

        healthStore.requestAuthorization(toShare: [], read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isSleepAuthorized = success
                self?.isWorkoutAuthorized = success
                completion(success)
            }
            if !success {
                print("HealthKit auth failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    /// Checks if the user has completed at least one workout today.
    ///
    /// This method centralizes the HealthKit workout query logic.
    /// Other managers, such as WorkoutManager, should delegate workout queries to this method to avoid code duplication.
    func hasCompletedWorkoutToday(completion: @escaping (Bool) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 1, sortDescriptors: nil) { _, samples, error in
            let found = (samples?.count ?? 0) > 0
            DispatchQueue.main.async {
                completion(found)
            }
        }
        healthStore.execute(query)
    }

    /// Call this from your JoyViewModel to refill joy if the user worked out today.
    /// For example:
    /// HealthManager.shared.refillJoyIfWorkedOutToday { didRefill in ... }
    func refillJoyIfWorkedOutToday(joyViewModel: JoyViewModel, completion: @escaping (Bool) -> Void) {
        hasCompletedWorkoutToday { didWorkout in
            if didWorkout {
                joyViewModel.joy = 100.0
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

// Usage in your JoyViewModel:
// HealthManager.shared.refillJoyIfWorkedOutToday(joyViewModel: self) { didRefill in ... }


