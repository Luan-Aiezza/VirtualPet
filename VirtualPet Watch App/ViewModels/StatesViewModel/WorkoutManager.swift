import Foundation
import HealthKit
import Combine

class WorkoutManager: ObservableObject {
    @Published var didWorkoutToday: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        checkWorkoutToday()
    }

    /// Verifica se o usuário fez algum exercício (workout) hoje
    func checkWorkoutToday() {
        HealthManager.shared.hasCompletedWorkoutToday { [weak self] didWorkout in
            self?.didWorkoutToday = didWorkout
        }
    }
}
