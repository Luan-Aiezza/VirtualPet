import Foundation
import SwiftUI
import Combine

class StatesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var sleepLevel: Double = 30.0
    @Published var joyLevel: Double = 30.0
    @Published var hungerLevel: Double = 30.0
    @Published var isSleeping: Bool = false
    @Published var isDead: Bool = false
    @Published var crownValue: Double = 0.0
    @Published var currentAsset: String = "WhiteCatIdle(Baby)1"
    @Published var evolutionStage: PetEvolutionStage = .baby
    @Published var lastActionTime: Date = Date()
    @Published var timeOfDeathStart: Date?
    @Published var birthDate: Date = Date()
    
    // MARK: - Computed Properties
    var currentBackground: String {
        switch Int(crownValue) {
        case 0: return "Kitchen"
        case 1: return "Bedroom"
        case 2: return "Room"
        default: return "Room"
        }
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let stateKey = "PetState"
    private var decayTimer: Timer?
    @Published var timer: AnyCancellable?
    
    // MARK: - Initialization
    init() {
        loadState()
        calculateOfflineDecay()
        updateEvolutionStage()
        startTimer()
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - State Management
    private func saveState() {
        let state = PetState(
            sleepLevel: sleepLevel,
            joyLevel: joyLevel,
            isSleeping: isSleeping,
            hungerLevel: hungerLevel,
            isDead: isDead,
            currentAsset: currentAsset,
            lastActionTime: lastActionTime,
            timeOfDeathStart: timeOfDeathStart,
            crownValue: crownValue,
            evolutionStage: evolutionStage,
            birthDate: birthDate
        )
        
        userDefaults.set(encodable: state, forKey: stateKey)
        userDefaults.synchronize()
    }
    
    private func loadState() {
        guard let state = userDefaults.get(PetState.self, forKey: stateKey) else { return }
        
        sleepLevel = state.sleepLevel
        joyLevel = state.joyLevel
        isSleeping = state.isSleeping
        hungerLevel = state.hungerLevel
        isDead = state.isDead
        currentAsset = state.currentAsset
        lastActionTime = state.lastActionTime
        timeOfDeathStart = state.timeOfDeathStart
        crownValue = state.crownValue
        evolutionStage = state.evolutionStage
        birthDate = state.birthDate
    }
}

// MARK: - Pet Actions Extension
extension StatesViewModel {
    func feedPet() {
        if canFeed() {
            hungerLevel = 100.0
            
            currentAsset = "WhiteCatFeed(\(evolutionStage.rawValue))1"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.currentAsset = "WhiteCatFeed(\(self.evolutionStage.rawValue))2"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.currentAsset = "WhiteCatFeed(\(self.evolutionStage.rawValue))3"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.currentAsset = "WhiteCatFeed(\(self.evolutionStage.rawValue))4"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.currentAsset = "WhiteCatFeed(\(self.evolutionStage.rawValue))5"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.currentAsset = "WhiteCatFeed(\(self.evolutionStage.rawValue))6"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.currentAsset = "WhiteCatFeed(\(self.evolutionStage.rawValue))7"
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        self.currentAsset = "WhiteCatFeed(\(self.evolutionStage.rawValue))8"
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            self.currentAsset = "WhiteCatIdle(\(self.evolutionStage.rawValue))1"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            showDenialAnimation()
        }
        saveState()
    }
    
    func toggleSleep() {
        isSleeping.toggle()
        currentAsset = isSleeping
            ? "WhiteCatSleep(\(evolutionStage.rawValue))1"
            : "WhiteCatIdle(\(evolutionStage.rawValue))1"
        saveState()
    }
    
    func playWithPet() {
        joyLevel = 100.0
        
        currentAsset = "WhiteCatPlaying(\(evolutionStage.rawValue))1"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentAsset = "WhiteCatPlaying(\(self.evolutionStage.rawValue))2"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.currentAsset = "WhiteCatPlaying(\(self.evolutionStage.rawValue))3"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.currentAsset = "WhiteCatPlaying(\(self.evolutionStage.rawValue))4"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.currentAsset = "WhiteCatPlaying(\(self.evolutionStage.rawValue))5"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.currentAsset = "WhiteCatPlaying(\(self.evolutionStage.rawValue))6"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.currentAsset = "WhiteCatPlaying(\(self.evolutionStage.rawValue))7"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.currentAsset = "WhiteCatIdle(\(self.evolutionStage.rawValue))1"
                                }
                            }
                        }
                    }
                }
            }
        }
        saveState()
    }
    
    private func showDenialAnimation() {
        currentAsset = "WhiteCatDenying(\(evolutionStage.rawValue))1"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentAsset = "WhiteCatDenying(\(self.evolutionStage.rawValue))2"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.currentAsset = "WhiteCatDenying(\(self.evolutionStage.rawValue))3"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.currentAsset = "WhiteCatIdle(\(self.evolutionStage.rawValue))1"
                }
            }
        }
    }
}

// MARK: - Timer and State Updates Extension
extension StatesViewModel {
    func startTimer() {
        //VOLTAR PARA 60
        decayTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.updatePetState()
        }
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    func updatePetState() {
        let currentTime = Date()
        let timeSinceLastAction = currentTime.timeIntervalSince(lastActionTime)
        
        updateEvolutionStage()
        guard !isDead else { return }
        
        updateHungerLevel(timeSinceLastAction)
        updateJoyLevel(timeSinceLastAction)
        updateSleepLevel(timeSinceLastAction)
        
        checkForDeath(now: currentTime)
        lastActionTime = currentTime
        saveState()
    }
    
    //VOLTAR PARA 12
    private func updateHungerLevel(_ timeSinceLastAction: TimeInterval) {
        let hungerDecayAmount = timeSinceLastAction / (12 * 60 * 60) * 100.0
        hungerLevel = max(0.0, hungerLevel - hungerDecayAmount)
    }
    
    private func updateJoyLevel(_ timeSinceLastAction: TimeInterval) {
        let joyDecayAmount = timeSinceLastAction / (24 * 60 * 60) * 100.0
        joyLevel = max(0.0, joyLevel - joyDecayAmount)
    }
    
    private func updateSleepLevel(_ timeSinceLastAction: TimeInterval) {
        if isSleeping {
            let sleepRecovery = timeSinceLastAction / (16 * 60 * 60) * 100.0
            sleepLevel += sleepRecovery
            if sleepLevel >= 100.0 {
                sleepLevel = 100.0
                toggleSleep()
            }
        } else {
            let sleepDecay = timeSinceLastAction / (16 * 60 * 60) * 100.0
            sleepLevel = max(0.0, sleepLevel - sleepDecay)
        }
    }
}

// MARK: - Evolution and Death Management Extension
extension StatesViewModel {
    private func updateEvolutionStage() {
        let now = Date()
        let age = Calendar.current.dateComponents([.month], from: birthDate, to: now).month ?? 0
        
        if age >= 4 {
            evolutionStage = .adult
        } else if age >= 1 {
            evolutionStage = .children
        } else {
            evolutionStage = .baby
        }
        
        if !currentAsset.contains("Dead") && !currentAsset.contains("Denying") && !currentAsset.contains("Feed") && !currentAsset.contains("Playing") {
            currentAsset = "WhiteCatIdle(\(evolutionStage.rawValue))1"
        }
    }
    
    private func checkForDeath(now: Date) {
        if hungerLevel <= 0 || sleepLevel <= 0 || joyLevel <= 0 {
            if timeOfDeathStart == nil {
                timeOfDeathStart = lastActionTime
            }
            
            if let deathStart = timeOfDeathStart, now.timeIntervalSince(deathStart) >= 24 * 3600 {
                isDead = true
                currentAsset = "Dead"
                stopTimer()
            }
        } else {
            timeOfDeathStart = nil
        }
    }
    
    func calculateOfflineDecay() {
        let currentTime = Date()
        let timeSinceLastAction = currentTime.timeIntervalSince(lastActionTime)
        
        let decayAmount = timeSinceLastAction / (12 * 60 * 60) * 100.0
        
        hungerLevel = max(0.0, hungerLevel - decayAmount)
        joyLevel = max(0.0, joyLevel - decayAmount)
        
        if isSleeping {
            sleepLevel = min(100.0, sleepLevel + (100.0 / (16 * 3600)) * timeSinceLastAction)
            if sleepLevel >= 100.0 {
                sleepLevel = 100.0
                toggleSleep()
            }
        } else {
            sleepLevel = max(0.0, sleepLevel - decayAmount)
        }
        
        if hungerLevel <= 0.0 || sleepLevel <= 0.0 || joyLevel <= 0.0 {
            if let deathStart = timeOfDeathStart {
                if currentTime.timeIntervalSince(deathStart) >= 60 * 60 {
                    isDead = true
                    currentAsset = "Dead"
                }
            } else {
                timeOfDeathStart = lastActionTime
            }
        } else {
            timeOfDeathStart = nil
        }
        
        lastActionTime = currentTime
        saveState()
    }
}

// MARK: - UI Helper Methods Extension
extension StatesViewModel {
    private func canFeed() -> Bool {
        //Verificar o que faz mais sentido
//        let timeUntilNextFeed = hungerLevel / 100.0 * 12 * 60 * 60
//        return timeUntilNextFeed <= 2.5 * 60 * 60
        return hungerLevel <= (100.0 / 12 * 3) && !isSleeping && !isDead
    }
    
    private func canSleep() -> Bool {
        return sleepLevel <= (100.0 / 16 * 8) && !isDead
    }
    
    private func canPlay() -> Bool {
        return joyLevel <= (100.0 / 24 * 9) && !isSleeping && !isDead
    }
    
    private func bindValue(value: Double) -> Binding<Double> {
        return Binding(get: { value }, set: { _ in })
    }
    
    @ViewBuilder
    func handleCrownValueButton() -> some View {
        let selectedIndex = Int(round(crownValue))
        
        switch selectedIndex {
        case 0:
            Button(action: feedPet) {
                Text("Feed").bold()
            }
            .colorMultiply(Color.yellow)
            .disabled(!canFeed())
            
        case 1:
            if isSleeping {
                Button(action: toggleSleep) {
                    Text("Awake").bold()
                }
            } else {
                Button(action: toggleSleep) {
                    Text("Sleep").bold()
                }
                .colorMultiply(Color.blue)
                .disabled(!canSleep())
            }
            
        case 2:
            Button(action: playWithPet) {
                Text("Play").bold()
            }
            .colorMultiply(Color.green)
            .disabled(!canPlay())
            
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func handleCrownValueProgressBar() -> some View {
        let selectedIndex = Int(round(crownValue))
        
        switch selectedIndex {
        case 0:
            ProgressBar(value: bindValue(value: hungerLevel), color: .yellow)
        case 1:
            ProgressBar(value: bindValue(value: sleepLevel), color: .blue)
        case 2:
            ProgressBar(value: bindValue(value: joyLevel), color: .green)
        default:
            EmptyView()
        }
    }
}
