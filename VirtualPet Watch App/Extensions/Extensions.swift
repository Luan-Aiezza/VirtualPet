import Foundation
import SwiftUI

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

extension PetManager {
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

extension PetManager {
    @ViewBuilder
    func handleCrownValueButton() -> some View {
        switch crownVM.currentState {
        case .hunger:
            Button("Feed") {
                self.feedPet()
            }
            .buttonStyle(.bordered)
            .tint(Color.yellow)
            .bold(true)
            .disabled(sleepVM.isSleeping || !hungerVM.canFeed())
            
        case .sleep:
            Button(sleepVM.isSleeping ? "Awake" : "Sleep") {
                self.toggleSleep()
            }
            .buttonStyle(.bordered)
            .tint(Color.purple)
            .bold(true)
            
        case .joy:
            Button("Play") {
                self.playWithPet()
            }
            .buttonStyle(.bordered)
            .tint(Color.green)
            .bold(true)
            .disabled(sleepVM.isSleeping || !joyVM.canplay())

        }
    }
}



