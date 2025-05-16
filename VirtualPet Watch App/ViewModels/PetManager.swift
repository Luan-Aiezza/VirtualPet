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
        animationController.setupScene(stage: evolutionManager.stage) // ← ESSENCIAL
        evaluateInitialAnimationState()
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

        evaluateSleepAutomatically()
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
//        let canSleep = sleepVM.canSleep()
        let wasSleeping = sleepVM.isSleeping

        if wasSleeping {
            // Acordar o pet mesmo que não possa "dormir"
            sleepVM.toggleSleep()
            animationController.updateSleepState(isSleeping: false, stage: evolutionManager.stage)
        }
//        else if canSleep {
//            // Dormir apenas se puder
//            sleepVM.toggleSleep()
//            animationController.updateSleepState(isSleeping: true, stage: evolutionManager.stage)
//        } else {
//            // Não pode dormir e estava acordado → negar
//            animationController.playDenial(for: evolutionManager.stage)
//        }
    }
    
    func evaluateSleepAutomatically() {
        if !sleepVM.isSleeping && sleepVM.shouldStartSleeping() {
            sleepVM.toggleSleep()
            animationController.updateSleepState(isSleeping: true, stage: evolutionManager.stage)
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

        if sleepVM.sleep <= 25 {
            animationController.startDrowsyAnimationLoop(stage: stage)
        } else if joyVM.joy <= 25 {
            animationController.startSadAnimationLoop(stage: stage)
        } else if hungerVM.hunger <= 25 {
            animationController.startHungryAnimationLoop(stage: stage)
        } else {
            animationController.resetToIdle()
        }
    }

    func evaluatePriority() {
        let stage = evolutionManager.stage

        if sleepVM.isSleeping {
            animationController.updateSleepState(isSleeping: true, stage: stage)
            return
        }

        if sleepVM.sleep <= 25 {
            animationController.startDrowsyAnimationLoop(stage: stage)
        } else if joyVM.joy <= 25 {
            animationController.startSadAnimationLoop(stage: stage)
        } else if hungerVM.hunger <= 25 {
            animationController.startHungryAnimationLoop(stage: stage)
        } else {
            animationController.resetToIdle()
        }
    }

    public func loadState() {
        hungerVM.hunger = UserDefaults.standard.double(forKey: "hunger")
        sleepVM.sleep = UserDefaults.standard.double(forKey: "sleep")
        joyVM.joy = UserDefaults.standard.double(forKey: "joy")

        if let birthDate = UserDefaults.standard.object(forKey: "birthDate") as? Date {
            lifeManager.birthDate = birthDate
        }

        if let lastActionTime = UserDefaults.standard.object(forKey: "lastActionTime") as? Date {
            lifeManager.lastActionTime = lastActionTime
        }
    }

    public func saveState() {
        UserDefaults.standard.set(hungerVM.hunger, forKey: "hunger")
        UserDefaults.standard.set(sleepVM.sleep, forKey: "sleep")
        UserDefaults.standard.set(joyVM.joy, forKey: "joy")
        UserDefaults.standard.set(lifeManager.birthDate, forKey: "birthDate")
        UserDefaults.standard.set(lifeManager.lastActionTime, forKey: "lastActionTime")
    }
}
