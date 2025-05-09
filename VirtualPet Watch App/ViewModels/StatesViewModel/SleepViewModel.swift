import SwiftUI
import Combine
import WatchKit
import Foundation

class SleepViewModel: ObservableObject {
    @Published var sleep: Double = 30.0
    @Published var isSleeping: Bool = false

    func update(interval: TimeInterval, isSleeping: Bool) {
        if isSleeping {
            sleep += interval / (0.016 * 3600) * 100
            if sleep >= 100 {
                sleep = 100
                self.isSleeping = false
            }
        } else {
            sleep = max(0, sleep - interval / (16 * 3600) * 100)
        }
    }
    
    func canSleep() -> Bool {
        sleep < 25.0 // 2.5 de margem
    }

    func toggleSleep() {
        isSleeping.toggle()
    }
}
