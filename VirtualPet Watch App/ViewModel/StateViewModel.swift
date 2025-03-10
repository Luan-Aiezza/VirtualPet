import SwiftUI
import Combine

class StatesViewModel: ObservableObject {
    @Published var sleepLevel: Double = 100.0
    @Published var joyLevel: Double = 100.0
    @Published var isSleeping: Bool = false
    @Published var hungerLevel: Double = 100.0
    
    @Published var isDead: Bool = false
    @Published var currentAsset: String = "WhiteCatIdle(Children)1"
    @Published var timer: AnyCancellable?
    @Published var lastActionTime: Date = Date()
    @Published var timeOfDeathStart: Date? = nil
    @Published var crownValue: Double = 0
    
    
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
