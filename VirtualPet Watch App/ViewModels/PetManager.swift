import SwiftUI
import Combine
import WatchKit
import Foundation
import UserNotifications

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
    private var lastSleepFetchDate: Date = .distantPast
    
    // Flags to control notification sending and avoid spam
    private var notifiedSleepy = false
    private var notifiedHungry = false
    private var notifiedSad = false
    
    init() {
        NotificationManager.shared.requestAuthorization()
        bindViewModels()
        loadState()
        // Adjust sleep data based on time elapsed since last action to keep sleep state accurate
        sleepVM.retroactivelyAddSleepIfNeeded(lastActionTime: lifeManager.lastActionTime)
        evolutionManager.updateStage(birthDate: lifeManager.birthDate)
        animationController.setupScene(stage: evolutionManager.stage) // ← ESSENCIAL
        evaluateInitialAnimationState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.startTimer()
        }
       //startTimer() antes
        evaluatePriority()
    }

    deinit { stopTimer() }

    private func bindViewModels() {
        
        sleepVM.sleepDataManager.$isUserInSleepMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inSleepMode in
                self?.handleUserSleepModeChange(isSleeping: inSleepMode)
            }
            .store(in: &cancellables)
        
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
    
    private func handleUserSleepModeChange(isSleeping: Bool) {
        let canSleep = sleepVM.canSleep()

        if isSleeping && !sleepVM.isSleeping && canSleep {
            // Entrar em sono automático via modo sono
            sleepVM.isSleeping = true
            animationController.updateSleepState(isSleeping: true, stage: evolutionManager.stage)
            print("🌙 Pet entrou em sono via modo sono do Apple Watch")
        } else if !isSleeping && sleepVM.isSleeping {
            // Acordar automaticamente ao sair do modo sono
            sleepVM.isSleeping = false
            animationController.updateSleepState(isSleeping: false, stage: evolutionManager.stage)
            print("☀️ Pet acordou automaticamente via fim do modo sono")
        }
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

        // Checa se é um novo dia
        if !Calendar.current.isDate(lastSleepFetchDate, inSameDayAs: now) {
            sleepVM.preloadSleepFromHealthData()
            lastSleepFetchDate = now
            UserDefaults.standard.set(lastSleepFetchDate, forKey: "lastSleepFetchDate")
        }

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
        let wasSleeping = sleepVM.isSleeping

        if wasSleeping {

            sleepVM.toggleSleep()
            animationController.updateSleepState(isSleeping: false, stage: evolutionManager.stage)
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
        
        // Sleep critical state check and notification
        if sleepVM.sleep <= 25 {
            animationController.startDrowsyAnimationLoop(stage: stage)
            if !notifiedSleepy {
                NotificationManager.shared.sendPetNotification(type: .sleepy(stage: stage), stage: stage)
                notifiedSleepy = true
            }
        } else {
            notifiedSleepy = false
        }

        // Joy critical state check and notification
        if joyVM.joy <= 25 {
            animationController.startSadAnimationLoop(stage: stage)
            if !notifiedSad {
                NotificationManager.shared.sendPetNotification(type: .sad(stage: stage), stage: stage)
                notifiedSad = true
            }
        } else {
            notifiedSad = false
        }

        // Hunger critical state check and notification
        if hungerVM.hunger <= 25 {
            animationController.startHungryAnimationLoop(stage: stage)
            if !notifiedHungry {
                NotificationManager.shared.sendPetNotification(type: .hungry(stage: stage), stage: stage)
                notifiedHungry = true
            }
        } else {
            notifiedHungry = false
        }
        
        // If none critical states are triggered, reset to idle if not sleeping and no other animations started
        if sleepVM.sleep > 25 && joyVM.joy > 25 && hungerVM.hunger > 25 && !sleepVM.isSleeping {
            animationController.resetToIdle()
        }
    }

    public func loadState() {
        hungerVM.hunger = UserDefaults.standard.double(forKey: "hunger")
        sleepVM.sleep = UserDefaults.standard.double(forKey: "sleep")
        joyVM.joy = UserDefaults.standard.double(forKey: "joy")
        
        if let lastSleepFetch = UserDefaults.standard.object(forKey: "lastSleepFetchDate") as? Date {
            self.lastSleepFetchDate = lastSleepFetch
        }

        if let birthDate = UserDefaults.standard.object(forKey: "birthDate") as? Date {
            lifeManager.birthDate = birthDate
        }

        if let lastActionTime = UserDefaults.standard.object(forKey: "lastActionTime") as? Date {
            lifeManager.lastActionTime = lastActionTime
        }
    }

    public func saveState() {
        UserDefaults.standard.set(lastSleepFetchDate, forKey: "lastSleepFetchDate")
        UserDefaults.standard.set(hungerVM.hunger, forKey: "hunger")
        UserDefaults.standard.set(sleepVM.sleep, forKey: "sleep")
        UserDefaults.standard.set(joyVM.joy, forKey: "joy")
        UserDefaults.standard.set(lifeManager.birthDate, forKey: "birthDate")
        UserDefaults.standard.set(lifeManager.lastActionTime, forKey: "lastActionTime")
    }
}

// Note: The notification assets (images or icons) used by NotificationManager 
// should be placed in your project’s Assets.xcassets folder with names matching 
// the assetName returned by NotificationManager for each notification type, 
// so the notifications display the corresponding images correctly.

