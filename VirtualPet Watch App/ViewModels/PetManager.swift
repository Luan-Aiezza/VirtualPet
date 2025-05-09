import SwiftUI
import Combine
import WatchKit
import Foundation

class PetManager: ObservableObject {
    @Published var hungerVM = HungerViewModel()
    @Published var sleepVM = SleepViewModel()
    @Published var joyVM = JoyViewModel()
    @Published var animationController = PetAnimationController()
    @Published var evolutionManager = EvolutionManager()
    @Published var lifeManager = LifeStateManager()
    @Published var crownVM = CrownViewModel()
    
    private var cancellables: Set<AnyCancellable> = []
    private var timer: Timer?
    
    init() {
        bindViewModels()
        loadState()
        evolutionManager.updateStage(birthDate: lifeManager.birthDate)
        startTimer()
    }

    deinit { stopTimer() }
    
    private func bindViewModels() {
        hungerVM.objectWillChange
            .merge(with: sleepVM.objectWillChange,
                   joyVM.objectWillChange,
                   animationController.objectWillChange,
                   evolutionManager.objectWillChange,
                   lifeManager.objectWillChange,
                   crownVM.objectWillChange)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    public func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateState()
        }
    }

    public func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    public func updateState() {
        let now = Date()
        let interval = now.timeIntervalSince(lifeManager.lastActionTime)
        lifeManager.lastActionTime = now

        hungerVM.update(interval: interval)
        sleepVM.update(interval: interval, isSleeping: sleepVM.isSleeping)
        joyVM.update(interval: interval)
        
        evolutionManager.updateStage(birthDate: lifeManager.birthDate)
        lifeManager.checkDeath(hunger: hungerVM.hunger, sleep: sleepVM.sleep, joy: joyVM.joy)
        
        saveState()
    }

    func feedPet() {
        if hungerVM.canFeed() {
            hungerVM.feed()
            animationController.playFeeding(for: evolutionManager.stage)
        } else {
            animationController.playDenial(for: evolutionManager.stage)
        }
    }

    func toggleSleep() {
        if sleepVM.canSleep() {
            sleepVM.toggleSleep()
            animationController.updateSleepState(isSleeping: sleepVM.isSleeping, stage: evolutionManager.stage)
        } else {
            animationController.playDenial(for: evolutionManager.stage)
        }
    }

    func playWithPet() {
        if joyVM.canplay() {
            joyVM.play()
            animationController.playPlaying(for: evolutionManager.stage)
        } else {
            animationController.playDenial(for: evolutionManager.stage)
        }
    }
}
