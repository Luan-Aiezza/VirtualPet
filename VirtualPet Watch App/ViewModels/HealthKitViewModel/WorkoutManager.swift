import Foundation
import HealthKit
import Combine

class WorkoutManager: ObservableObject {
    @Published var didWorkoutToday: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private var workoutObserverQuery: HKObserverQuery?

    init() {
        checkWorkoutToday()
        startObservingWorkouts()
    }

    /// Verifica se o usuário fez algum exercício (workout) hoje
    func checkWorkoutToday() {
        HealthManager.shared.hasCompletedWorkoutToday { [weak self] didWorkout in
            self?.didWorkoutToday = didWorkout
        }
    }

    private func startObservingWorkouts() {
        let workoutType = HKObjectType.workoutType()
        workoutObserverQuery = HKObserverQuery(sampleType: workoutType, predicate: nil) { [weak self] query, completionHandler, error in
            guard error == nil else {
                print("Workout observer error: \(error!.localizedDescription)")
                completionHandler()
                return
            }
            self?.checkWorkoutToday()
            completionHandler()
        }
        if let query = workoutObserverQuery {
            HealthManager.shared.healthStore.execute(query)
        }
    }

    deinit {
        if let query = workoutObserverQuery {
            HealthManager.shared.healthStore.stop(query)
        }
    }
}
