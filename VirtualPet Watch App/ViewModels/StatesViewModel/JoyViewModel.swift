import SwiftUI
import Combine
import WatchKit
import Foundation

class JoyViewModel: ObservableObject {
    @Published var joy: Double = 25.0
    @Published var workoutManager = WorkoutManager()
    private var playingTimer: Timer?
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        workoutManager.$didWorkoutToday
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] didWorkout in
                guard let self = self else { return }
                if didWorkout && self.joy < 100 {
                    self.joy = 100
                    print("🏃‍♂️ Pet ficou feliz pois você fez exercício! Joy = 100%")
                }
            }
            .store(in: &cancellables)
    }

    func update(interval: TimeInterval) {
        joy = max(0, joy - interval / (24 * 3600) * 100)
    }

    func play() {
        playingTimer?.invalidate()
        let duration: TimeInterval = 2.0
        let startValue = joy
        let endValue = 100.0
        let steps = Int(duration * 30) // 30 updates por segundo
        let increment = (endValue - startValue) / Double(steps)
        var currentStep = 0
        playingTimer = Timer.scheduledTimer(withTimeInterval: duration / Double(steps), repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            if currentStep >= steps {
                self.joy = endValue
                timer.invalidate()
                return
            }
            self.joy = min(endValue, self.joy + increment)
            currentStep += 1
        }
    }
    
    func canplay() -> Bool {
        joy < 25.0 // 2.5 de margem
    }
}

