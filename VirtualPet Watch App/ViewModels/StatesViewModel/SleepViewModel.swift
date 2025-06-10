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
        //        if isSleeping {
        //            let targetDuration = sleepDataManager.averageSleepDuration
        //            sleep += interval / targetDuration * 100
        //            if sleep >= 100 {
        //                sleep = 100
        //            }
        //        } else {
        sleep = max(0, sleep - interval / (16 * 3600) * 100)
        //        }
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
}
