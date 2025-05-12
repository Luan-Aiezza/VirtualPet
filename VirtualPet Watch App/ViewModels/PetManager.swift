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
        evaluateInitialAnimationState()
        evolutionManager.updateStage(birthDate: lifeManager.birthDate)
        startTimer()
        evaluatePriority()
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

        sleepVM.update(interval: interval, isSleeping: sleepVM.isSleeping)
        hungerVM.update(interval: interval)
        joyVM.update(interval: interval)

        evolutionManager.updateStage(birthDate: lifeManager.birthDate)
        lifeManager.checkDeath(hunger: hungerVM.hunger, sleep: sleepVM.sleep, joy: joyVM.joy)

        evaluatePriority()

        saveState()
    }

    func feedPet() {
        if hungerVM.canFeed() {
            hungerVM.feed()
            animationController.playFeeding(for: evolutionManager.stage)
        }
    }

    func toggleSleep() {
        if sleepVM.isSleeping {
            sleepVM.toggleSleep()
            animationController.updateSleepState(isSleeping: sleepVM.isSleeping, stage: evolutionManager.stage)
        } else if sleepVM.canSleep() {
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
        }
    }
    
    public func evaluateInitialAnimationState() {
        let stage = evolutionManager.stage
        
        if sleepVM.isSleeping {
            animationController.updateSleepState(isSleeping: true, stage: stage)
            return
        }
        
        // Avaliação de necessidades por prioridade
        if sleepVM.sleep <= 25 {
            animationController.startDrowsyAnimationLoop(stage: stage)
        } else if joyVM.joy <= 25 {
            animationController.startSadAnimationLoop(stage: stage)
        } else if hungerVM.hunger <= 25 {
            animationController.startHungryAnimationLoop(stage: stage)
        } else {
            animationController.resetToIdle()
            animationController.startIdleAnimation()
        }
    }
}
