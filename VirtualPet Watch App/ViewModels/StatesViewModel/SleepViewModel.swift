import SwiftUI
import Combine
import WatchKit
import Foundation

class SleepViewModel: ObservableObject {
    @Published var sleep: Double = 25.0
    @Published var isSleeping: Bool = false
    @Published var sleepDataManager = SleepDataManager()

    func update(interval: TimeInterval, isSleeping: Bool) {
        if isSleeping {
            let targetDuration = sleepDataManager.averageSleepDuration
            sleep += interval / targetDuration * 100
            if sleep >= 100 {
                sleep = 100
            }
        } else {
            sleep = max(0, sleep - interval / (16 * 3600) * 100)
        }
    }

    func shouldStartSleeping() -> Bool {
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let bedtime = sleepDataManager.averageBedtime

        guard let nowHour = now.hour, let bedtimeHour = bedtime.hour else { return false }

        // Se está dentro de 1h antes ou depois do horário médio
        let difference = abs(nowHour - bedtimeHour)
        return difference <= 1 && canSleep()
    }

    func canSleep() -> Bool {
        sleep < 25.0
    }

    func toggleSleep() {
        isSleeping.toggle()
    }
}
