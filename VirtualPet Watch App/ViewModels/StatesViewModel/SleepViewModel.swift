import SwiftUI
import Combine
import WatchKit
import Foundation

class SleepViewModel: ObservableObject {
    @Published var sleep: Double = 25.0
    @Published var isSleeping: Bool = UserDefaults.standard.bool(forKey: "isSleeping")
    @Published var sleepDataManager = SleepDataManager()

    private var cancellables: Set<AnyCancellable> = []

    init() {
        sleepDataManager.$isUserInSleepMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inSleepMode in
                self?.handleSleepStateChange(isSleeping: inSleepMode)
            }
            .store(in: &cancellables)
        preloadSleepFromHealthData()
    }

    private func handleSleepStateChange(isSleeping: Bool) {
        if isSleeping && self.canSleep() {
            self.isSleeping = true
            UserDefaults.standard.set(self.isSleeping, forKey: "isSleeping")
        }
    }
    //NOVA FUNÇÃO
    func preloadSleepFromHealthData() {
        sleepDataManager.fetchLastNightSleep { [weak self] duration in
            guard let self = self else { return }
            let cappedDuration = min(duration, 8 * 3600) // máximo 8h
            self.sleep = (cappedDuration / (8 * 3600)) * 100
        }
    }
    
    func update(interval: TimeInterval, isSleeping: Bool) {
        if isSleeping {
            // Recupera sono manualmente ou pelo modo sono (até no máximo 100)
            sleep = min(100, sleep + interval / (8 * 3600) * 100)
        } else {
            // Gasta sono normalmente
            sleep = max(0, sleep - interval / (16 * 3600) * 100)
        }
    }

    func canSleep() -> Bool {
        sleep < 25.0
    }

    // Só permite o usuário acordar manualmente
    func toggleSleep() {
        if isSleeping {
            isSleeping = false
            UserDefaults.standard.set(self.isSleeping, forKey: "isSleeping")
        }
    }

    /// If the user was in sleep mode while the app was closed, increment the sleep bar accordingly (up to 8 hours max).
    /// Uses the lastActionTime as the reference for when the app last updated state.
    func retroactivelyAddSleepIfNeeded(lastActionTime: Date) {
        // If user is currently in sleep mode
        if sleepDataManager.isUserInSleepMode {
            let now = Date()
            // Calculate the interval since lastActionTime
            let sleptInterval = now.timeIntervalSince(lastActionTime)
            // If positive and plausible (i.e., less than 12h)
            if sleptInterval > 0 && sleptInterval < 60 * 60 * 12 {
                // Calculate the amount to add based on 8 hours full recovery
                let maxSleepTime: TimeInterval = 8 * 3600
                let percentToAdd = (sleptInterval / maxSleepTime) * 100
                self.sleep = min(100, self.sleep + percentToAdd)
            }
        }
    }
}

