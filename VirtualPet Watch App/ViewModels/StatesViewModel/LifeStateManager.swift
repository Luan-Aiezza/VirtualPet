import SwiftUI
import Combine
import WatchKit
import Foundation

class LifeStateManager: ObservableObject {
    @Published var isDead = true
    @Published var timeOfDeathStart: Date?
    @Published var lastActionTime: Date = Date()
    @Published var birthDate: Date = Date()
    

    func checkDeath(hunger: Double, sleep: Double, joy: Double) {
        if hunger <= 0 || sleep <= 0 || joy <= 0 {
            if timeOfDeathStart == nil {
                timeOfDeathStart = Date()
            } else if let start = timeOfDeathStart, Date().timeIntervalSince(start) >= 48 * 3600 {
                isDead = true
            }
        } else {
            timeOfDeathStart = nil
        }
    }
}
