import Foundation
import SwiftUI
import Combine

enum PetEvolutionStage: String, Codable {
    case baby = "Baby"
    case children = "Children"
    case adult = "Adult"
}

class StatesViewModel: ObservableObject {
    @Published var sleepLevel: Double = 100.0
    @Published var joyLevel: Double = 100.0
    @Published var isSleeping: Bool = false
    @Published var hungerLevel: Double = 100.0
    @Published var isDead: Bool = false
    @Published var currentAsset: String = "WhiteCatIdle(Baby)1"
    @Published var lastActionTime: Date = Date()
    @Published var timeOfDeathStart: Date?
    @Published var crownValue: Double = 0.0
    @Published var evolutionStage: PetEvolutionStage = .baby
    @Published var birthDate: Date = Date()
    @Published var timer: AnyCancellable?
    
    init() {
        loadState()
        calculateOfflineDecay()
        updateEvolutionStage()
        startTimer()
    }
    
    deinit {
        stopTimer()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let stateKey = "PetState"
    private var decayTimer: Timer?
    
    private struct PetState: Codable {
        let sleepLevel: Double
        let joyLevel: Double
        let isSleeping: Bool
        let hungerLevel: Double
        let isDead: Bool
        let currentAsset: String
        let lastActionTime: Date
        let timeOfDeathStart: Date?
        let crownValue: Double
        let evolutionStage: PetEvolutionStage
        let birthDate: Date
    }
    
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
        
        let encoder = JSONEncoder()
        let encoded = try? encoder.encode(state)
        userDefaults.set(encoded, forKey: stateKey)
        userDefaults.synchronize()
    }
    
    private func loadState() {
        //        if let state = userDefaults.get(PetState.self, forKey: stateKey) {
        //            sleepLevel = state.sleepLevel
        //            joyLevel = state.joyLevel
        //            isSleeping = state.isSleeping
        //            hungerLevel = state.hungerLevel
        //            isDead = state.isDead
        //            currentAsset = state.currentAsset
        //            lastActionTime = state.lastActionTime
        //            timeOfDeathStart = state.timeOfDeathStart
        //            crownValue = state.crownValue
        //            evolutionStage = state.evolutionStage
        //            birthDate = state.birthDate
        //        }
        
        guard let state = userDefaults.data(forKey: stateKey) else { return }
        let decoder = JSONDecoder()
        let decoded = try? decoder.decode(PetState.self, from: state)
        
        if let decoded = decoded {
            sleepLevel = decoded.sleepLevel
            joyLevel = decoded.joyLevel
            isSleeping = decoded.isSleeping
            hungerLevel = decoded.hungerLevel
            isDead = decoded.isDead
            currentAsset = decoded.currentAsset
            lastActionTime = decoded.lastActionTime
            timeOfDeathStart = decoded.timeOfDeathStart
        }
    }
    
    func feedPet() {
        if canFeed() {
            hungerLevel = 100.0
            currentAsset = "WhiteCatFeed(\(evolutionStage.rawValue))1"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.currentAsset = "WhiteCatIdle(\(self.evolutionStage.rawValue))1"
            }
        } else {
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
        joyLevel = min(100.0, joyLevel + 20.0)
        crownValue += 10
        currentAsset = "WhiteCatPlay(\(evolutionStage.rawValue))1"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.currentAsset = "WhiteCatIdle(\(self.evolutionStage.rawValue))1"
        }
        saveState()
    }
    
    private func canFeed() -> Bool {
        let timeUntilNextFeed = hungerLevel / 100.0 * 12 * 60 * 60
        return timeUntilNextFeed <= 2.5 * 60 * 60
    }
    
    public func startTimer() {
        decayTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.updatePetState()
        }
    }
    
    func updatePetState() {
        let currentTime = Date()
        let timeSinceLastAction = currentTime.timeIntervalSince(lastActionTime)
        
        updateEvolutionStage()
        
        guard !isDead else { return }
        
        let decayAmount = timeSinceLastAction / (12 * 60 * 60) * 100.0
        hungerLevel = max(0.0, hungerLevel - decayAmount)
        
        if hungerLevel <= 0.0 {
            if let deathStart = timeOfDeathStart {
                if currentTime.timeIntervalSince(deathStart) >= 60 * 60 {
                    isDead = true
                    currentAsset = "Dead"
                    decayTimer?.invalidate()
                }
            } else {
                timeOfDeathStart = currentTime
            }
        } else {
            timeOfDeathStart = nil
        }
        
        lastActionTime = currentTime
        saveState()
    }
    
    private func calculateOfflineDecay() {
        let currentTime = Date()
        let timeSinceLastAction = currentTime.timeIntervalSince(lastActionTime)
        
        guard !isDead else { return }
        
        let decayAmount = timeSinceLastAction / (12 * 60 * 60) * 100.0
        hungerLevel = max(0.0, hungerLevel - decayAmount)
        
        if hungerLevel <= 0.0 {
            if let deathStart = timeOfDeathStart {
                if currentTime.timeIntervalSince(deathStart) >= 60 * 60 {
                    isDead = true
                    currentAsset = "Dead"
                }
            } else {
                timeOfDeathStart = currentTime
            }
        } else {
            timeOfDeathStart = nil
        }
        
        saveState()
    }
    
    private func updateEvolutionStage() {
        let now = Date()
        let age = Calendar.current.dateComponents([.month], from: birthDate, to: now).month ?? 0
        
        if age >= 4 {
            evolutionStage = .adult
            currentAsset = "WhiteCatIdle(\(evolutionStage.rawValue))1"
            
        } else if age >= 1 {
            evolutionStage = .children
            currentAsset = "WhiteCatIdle(\(evolutionStage.rawValue))1"
        } else {
            evolutionStage = .baby
            currentAsset = "WhiteCatIdle(\(evolutionStage.rawValue))1"
        }
    }
    
    // MARK: - Offline Decay Calculation
    
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
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func canSleep() -> Bool {
        return sleepLevel <= (100.0 / 16 * 9) && !isDead
    }
    
    private func canPlay() -> Bool {
        return joyLevel <= (100.0 / 24 * 9) && !isSleeping && !isDead
    }
    
    private func recoverySleepLevel(_ timeSinceLastAction: TimeInterval) {
        if isSleeping {
            sleepLevel += (100.0 / (16 * 3600)) * timeSinceLastAction
            
            if sleepLevel >= 100.0 {
                sleepLevel = 100.0
                toggleSleep() // Acorda automaticamente quando atinge 100%
            }
        }
    }
    
    private func bindValue(value: Double) -> Binding<Double> {
        let value = Binding(
            get: { value },
            set: { _ in }
        )
        return value
    }
    
    @ViewBuilder
    func handleCrownValueProgressBar() -> some View {
        let selectedIndex = Int(round(crownValue))
        
        switch selectedIndex {
        case 0:
            let hunger = bindValue(value: hungerLevel)
            ProgressBar(value:hunger, color: .red)
            Button(action: feedPet) {
                Text("Alimentar")
            }
            .disabled(!canFeed())
            
        case 1:
            let sleep = bindValue(value: sleepLevel)
            ProgressBar(value: sleep, color: .blue)
            switch isSleeping{
                
            case false:
                Button(action: toggleSleep) {
                    Text("Dormir")
                }.disabled(!canSleep())
                
            case true:
                Button(action: toggleSleep) {
                    Text("Acordar")
                }
                
            }
            
        case 2:
            let joy = bindValue(value: joyLevel)
            ProgressBar(value: joy, color: .green)
            Button(action: playWithPet) {
                Text("Brincar")
            }
            .disabled(!canPlay())
            
        default:
            EmptyView()
        }
    }
}

extension UserDefaults {
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    
    func get<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
}
