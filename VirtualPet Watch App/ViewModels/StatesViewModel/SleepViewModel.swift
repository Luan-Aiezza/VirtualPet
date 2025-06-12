import SwiftUI
import Combine
import WatchKit
import Foundation

class SleepViewModel: ObservableObject {
    @Published var sleep: Double = 25.0
    @Published var isSleeping: Bool = false
    @Published var sleepDataManager = SleepDataManager()

    private var cancellables: Set<AnyCancellable> = []

    init() {
        sleepDataManager.$isUserInSleepMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inSleepMode in
                self?.handleSleepStateChange(isSleeping: inSleepMode)
            }
            .store(in: &cancellables)

        sleepDataManager.requestAuthorization()
        preloadSleepFromHealthData()
    }

    private func handleSleepStateChange(isSleeping: Bool) {
        if isSleeping && self.canSleep() {
            self.isSleeping = true
            print("Pet começou a dormir via modo sono")
        } else if !isSleeping && self.isSleeping {
            self.isSleeping = false
            print("Pet acordou automaticamente")
        }
    }
    //NOVA FUNÇÃO
    func preloadSleepFromHealthData() {
        sleepDataManager.fetchLastNightSleep { [weak self] duration in
            guard let self = self else { return }
            let cappedDuration = min(duration, 8 * 3600) // máximo 8h
            self.sleep = (cappedDuration / (8 * 3600)) * 100
            print("⏰ Sono carregado: \(duration / 3600)h → \(self.sleep)%")
        }
    }
    
    func update(interval: TimeInterval, isSleeping: Bool) {
        sleep = max(0, sleep - interval / (16 * 3600) * 100)
    }

    func canSleep() -> Bool {
        sleep < 25.0
    }

    // Só permite o usuário acordar manualmente
    func toggleSleep() {
        if isSleeping {
            isSleeping = false
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
                print("[Retroactive Sleep] Added \(percentToAdd)% sleep for interval: \(sleptInterval/3600)h")
            }
        }
    }
}
