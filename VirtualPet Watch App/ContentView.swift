import SwiftUI
import Combine
import WatchKit

struct ContentView: View {
    
    @ObservedObject private var vm = StatesViewModel()
    
    var body: some View {
        VStack {
            Image(vm.currentAsset)
                .resizable()
                .scaledToFit()
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    vm.updatePetState()
                }
            
            vm.handleCrownValueProgressBar()
//            switch selectedIndex {
//            case 0:
//                ProgressBar(value: $hungerLevel, color: .red)
//                Button(action: feedPet) {
//                    Text("Alimentar")
//                }
//                .disabled(!canFeed())
//                
//            case 1:
//                ProgressBar(value: $sleepLevel, color: .blue)
//                switch isSleeping{
//                    
//                case false:
//                    Button(action: toggleSleep) {
//                        Text("Dormir")
//                    }.disabled(!canSleep())
//                    
//                case true:
//                    Button(action: toggleSleep) {
//                        Text("Acordar")
//                    }
//                    
//                }
//                
//            case 2:
//                ProgressBar(value: $playLevel, color: .green)
//                Button(action: playWithPet) {
//                    Text("Brincar")
//                }
//                .disabled(!canPlay())
//                
//            default:
//                EmptyView()
//            }
            
        }
        .focusable()
        .digitalCrownRotation($vm.crownValue, from: 0, through: 2, by: 1.0, sensitivity: .low)
        .onAppear {
            vm.startTimer()
            
        }
        .onDisappear {
            vm.stopTimer()
        }
    }
    
    //    private func startTimer() {
    //        timer = Timer.publish(every: 1, on: .main, in: .common)
    //            .autoconnect()
    //            .sink { _ in
    //                updatePetState()
    //            }
    //    }
    //
    //    private func stopTimer() {
    //        timer?.cancel()
    //        timer = nil
    //    }
    //
    //    private func updatePetState() {
    //        let currentTime = Date()
    //        let timeSinceLastAction = currentTime.timeIntervalSince(lastActionTime)
    //
    //        if isSleeping {
    //            recoverySleepLevel(timeSinceLastAction)
    //        } else {
    //            hungerLevel -= (100.0 / (0.012 * 3600)) * timeSinceLastAction
    //            sleepLevel -= (100.0 / (0.016 * 3600)) * timeSinceLastAction
    //            joyLevel -= (100.0 / (0.024 * 3600)) * timeSinceLastAction
    //        }
    //
    //        // Verifica se algum nível chegou a 0
    //        if hungerLevel <= 0 || sleepLevel <= 0 || playLevel <= 0 {
    //            if timeOfDeathStart == nil {
    //                timeOfDeathStart = currentTime // Registra o momento do colapso
    //            }
    //        } else {
    //            timeOfDeathStart = nil // Reseta se pelo menos um nível for restaurado
    //        }
    //
    //        // Se passaram 24 horas desde o colapso, mata o pet
    //        if let deathStart = timeOfDeathStart, currentTime.timeIntervalSince(deathStart) >= 0.024 * 3600 {
    //            isDead = true
    //            currentAsset = "Morto1"
    //            stopTimer()
    //        }
    //
    //        lastActionTime = currentTime
    //    }
    //
    //    private func canFeed() -> Bool {
    //        return hungerLevel <= (100.0 / 12 * 9) && !isSleeping && !isDead
    //    }
    //
    //    private func canSleep() -> Bool {
    //        return sleepLevel <= (100.0 / 16 * 9) && !isDead
    //    }
    //
    //    private func canPlay() -> Bool {
    //        return playLevel <= (100.0 / 24 * 9) && !isSleeping && !isDead
    //    }
    //
    //    private func feedPet() {
    //        if canFeed() {
    //            hungerLevel = 100.0
    //            currentAsset = "Comendo1"
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    //                currentAsset = "Idle1"
    //            }
    //        } else {
    //            currentAsset = "Negando1"
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    //                currentAsset = "Negando2"
    //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    //                    currentAsset = "Negando3"
    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    //                        currentAsset = "Idle1"
    //                    }
    //                }
    //            }
    //        }
    //    }
    //
    //    private func toggleSleep() {
    //        if isSleeping { // Se estiver dormindo, acorda
    //            isSleeping = false
    //            currentAsset = "Idle1"
    //        } else if canSleep() { // Só pode dormir se a condição permitir
    //            isSleeping = true
    //            currentAsset = "Dormindo1"
    //        } else { // Se não puder dormir, mostra animação de negação
    //            currentAsset = "Negando1"
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    //                currentAsset = "Negando2"
    //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    //                    currentAsset = "Negando3"
    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    //                        currentAsset = "Idle1"
    //                    }
    //                }
    //            }
    //        }
    //
    //        lastActionTime = Date()
    //    }
    //
    //    private func recoverySleepLevel(_ timeSinceLastAction: TimeInterval) {
    //        if isSleeping {
    //            sleepLevel += (100.0 / (16 * 3600)) * timeSinceLastAction
    //
    //            if sleepLevel >= 100.0 {
    //                sleepLevel = 100.0
    //                toggleSleep() // Acorda automaticamente quando atinge 100%
    //            }
    //        }
    //    }
    //
    //    private func playWithPet() {
    //        if canPlay() {
    //            joyLevel = 100.0
    //            currentAsset = "Doente1"
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    //                currentAsset = "Idle1"
    //            }
    //        } else {
    //            currentAsset = "Negando1"
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    //                currentAsset = "Negando2"
    //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    //                    currentAsset = "Negando3"
    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    //                        currentAsset = "Idle1"
    //                    }
    //                }
    //            }
    //        }
    //    }
}

struct ProgressBar: View {
    @Binding var value: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
                    .frame(
                        width: max(0, min(CGFloat(self.value) * geometry.size.width / 100, geometry.size.width)),
                        height: geometry.size.height
                    )
                    .foregroundColor(color)
            }
        }.frame(height: 10)
            .padding(.horizontal, 12)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
