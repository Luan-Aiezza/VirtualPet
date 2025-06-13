import SwiftUI
import Combine
import WatchKit
import Foundation

class HungerViewModel: ObservableObject {
    @Published var hunger: Double = 25.0
    private var feedingTimer: Timer?

    func update(interval: TimeInterval) {
        let decay = interval / (12 * 3600) * 100
        hunger = max(0, hunger - decay)
    }

    func feed() {
        feedingTimer?.invalidate()
        let duration: TimeInterval = 2.0
        let startValue = hunger
        let endValue = 100.0
        let steps = Int(duration * 30) // 30 updates per second
        let increment = (endValue - startValue) / Double(steps)
        var currentStep = 0
        feedingTimer = Timer.scheduledTimer(withTimeInterval: duration / Double(steps), repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            if currentStep >= steps {
                self.hunger = endValue
                timer.invalidate()
                return
            }
            self.hunger = min(endValue, self.hunger + increment)
            currentStep += 1
        }
    }

    func canFeed() -> Bool {
        hunger < 25.0 // 2.5 de margem
    }
}
