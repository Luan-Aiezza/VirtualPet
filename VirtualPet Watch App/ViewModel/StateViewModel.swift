import SwiftUI
import Combine

class StatesViewModel: ObservableObject {
    @Published var sleepLevel: Double = 100.0 {
        didSet { saveState() }
    }
    @Published var joyLevel: Double = 100.0 {
        didSet { saveState() }
    }
    @Published var isSleeping: Bool = false {
        didSet { saveState() }
    }
    @Published var hungerLevel: Double = 100.0 {
        didSet { saveState() }
    }
    
    @Published var isDead: Bool = false {
        didSet { saveState() }
    }
    @Published var currentAsset: String = "WhiteCatIdle(Children)1" {
        didSet { saveState() }
    }
    @Published var timer: AnyCancellable?
    @Published var lastActionTime: Date = Date() {
        didSet { saveState() }
    }
    @Published var timeOfDeathStart: Date? = nil {
        didSet { saveState() }
    }
    @Published var crownValue: Double = 0 {
        didSet { saveState() }
    }
    
    private let userDefaults = UserDefaults.standard
    private let stateKey = "petState"
    
    init() {
        loadState()
        calculateOfflineDecay()
        startTimer()
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - State Persistence
    
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
            crownValue: crownValue
        )
        userDefaults.set(encodable: state, forKey: stateKey)
    }
    
    private func loadState() {
        if let state = userDefaults.get(PetState.self, forKey: stateKey) {
            sleepLevel = state.sleepLevel
            joyLevel = state.joyLevel
            isSleeping = state.isSleeping
            hungerLevel = state.hungerLevel
            isDead = state.isDead
            currentAsset = state.currentAsset
            lastActionTime = state.lastActionTime
            timeOfDeathStart = state.timeOfDeathStart
            crownValue = state.crownValue
        }
    }
    
    // MARK: - Offline Decay Calculation
    
    private func calculateOfflineDecay() {
        let now = Date()
        let timeSinceLastAction = now.timeIntervalSince(lastActionTime)
        
        if timeSinceLastAction > 0 {
            if isSleeping {
                // Durante o sono offline, apenas recupera energia
                sleepLevel += (100.0 / (16 * 3600)) * timeSinceLastAction
                if sleepLevel >= 100.0 {
                    sleepLevel = 100.0
                    isSleeping = false
                    currentAsset = "WhiteCatIdle(Children)1"
                }
            } else {
                // Decaimento normal dos status
                hungerLevel -= (100.0 / (12 * 3600)) * timeSinceLastAction
                sleepLevel -= (100.0 / (16 * 3600)) * timeSinceLastAction
                joyLevel -= (100.0 / (24 * 3600)) * timeSinceLastAction
                
                // Garante que os valores não fiquem negativos
                hungerLevel = max(0, hungerLevel)
                sleepLevel = max(0, sleepLevel)
                joyLevel = max(0, joyLevel)
            }
            
            // Verifica se o pet morreu durante o tempo offline
            checkForDeath(now: now)
            
            lastActionTime = now
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
    
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
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
        
        if isSleeping {
            recoverySleepLevel(timeSinceLastAction)
        } else {
            hungerLevel -= (100.0 / (0.012 * 3600)) * timeSinceLastAction
            sleepLevel -= (100.0 / (0.016 * 3600)) * timeSinceLastAction
            joyLevel -= (100.0 / (0.024 * 3600)) * timeSinceLastAction
        }
        
        // Verifica se algum nível chegou a 0
        if hungerLevel <= 0 || sleepLevel <= 0 || joyLevel <= 0 {
            if timeOfDeathStart == nil {
                timeOfDeathStart = currentTime // Registra o momento do colapso
            }
        } else {
            timeOfDeathStart = nil // Reseta se pelo menos um nível for restaurado
        }
        
        // Se passaram 24 horas desde o colapso, mata o pet
        if let deathStart = timeOfDeathStart, currentTime.timeIntervalSince(deathStart) >= 0.024 * 3600 {
            isDead = true
            currentAsset = "Dead"
            stopTimer()
        }
        
        lastActionTime = currentTime
    }
    
    private func canFeed() -> Bool {
        return hungerLevel <= (100.0 / 12 * 9) && !isSleeping && !isDead
    }
    
    private func canSleep() -> Bool {
        return sleepLevel <= (100.0 / 16 * 9) && !isDead
    }
    
    private func canPlay() -> Bool {
        return joyLevel <= (100.0 / 24 * 9) && !isSleeping && !isDead
    }
    
    private func feedPet() {
        if canFeed() {
            hungerLevel = 100.0
            currentAsset = "WhiteCatFeed(Children)1"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.currentAsset = "WhiteCatIdle(Children)1"
            }
        } else {
            currentAsset = "WhiteCatDenying(Children)1"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.currentAsset = "WhiteCatDenying(Children)2"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.currentAsset = "WhiteCatDenying(Children)3"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.currentAsset = "WhiteCatIdle(Children)1"
                    }
                }
            }
        }
    }
    
    private func toggleSleep() {
        if isSleeping { // Se estiver dormindo, acorda
            isSleeping = false
            currentAsset = "WhiteCatIdle(Children)1"
        } else if canSleep() { // Só pode dormir se a condição permitir
            isSleeping = true
            currentAsset = "WhiteCatSleep(Children)1"
        } else { // Se não puder dormir, mostra animação de negação
            currentAsset = "WhiteCatDenying(Children)1"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.currentAsset = "WhiteCatDenying(Children)2"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.currentAsset = "WhiteCatDenying(Children)3"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.currentAsset = "WhiteCatIdle(Children)1"
                    }
                }
            }
        }
        
        lastActionTime = Date()
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
    
    private func playWithPet() {
        if canPlay() {
            joyLevel = 100.0
            currentAsset = "WhiteCatSad(Children)1"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.currentAsset = "WhiteCatIdle(Children)1"
            }
        } else {
            currentAsset = "WhiteCatDenying(Children)1"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.currentAsset = "WhiteCatDenying(Children)2"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.currentAsset = "WhiteCatDenying(Children)3"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.currentAsset = "WhiteCatIdle(Children)1"
                    }
                }
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
