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
    enum PetNeedState: String, Codable {
        case sleepy, hungry, sad, idle
    }

    private func determinePriorityState() -> PetNeedState {
        if sleepVM.sleep < 25.0 {
            return .sleepy
        } else if hungerVM.hunger < 25.0 {
            return .hungry
        } else if joyVM.joy < 25.0 {
            return .sad
        } else {
            return .idle
        }
    }

}

extension PetManager {
    @ViewBuilder
    public func handleCrownValueButton() -> some View {
        switch crownVM.currentState {
        case .hunger:
            if !sleepVM.isSleeping && hungerVM.canFeed() {
                Button("Feed") {
                    self.feedPet()
                }
                .buttonStyle(.bordered)
                .tint(Color.yellow)
                .font(Font.body.bold())
            } else {
                EmptyView()
            }
        case .sleep:
            if !sleepVM.isHealthKitAuthorized {
                Button(sleepVM.isSleeping ? "Awake" : "Sleep") {
                    self.toggleSleep()
                }
                .buttonStyle(.bordered)
                .tint(Color.indigo)
                .font(Font.body.bold())
            } else if sleepVM.isSleeping /*&& sleepVM.canAwake()*/ {
                Button("Awake") {
                    self.toggleSleep()
                }
                .buttonStyle(.bordered)
                .tint(Color.indigo)
                .font(Font.body.bold())
            } else {
                EmptyView()
            }
        case .joy:
            if !sleepVM.isSleeping && joyVM.canplay() {
                Button("Play") {
                    self.playWithPet()
                }
                .buttonStyle(.bordered)
                .tint(Color.green)
                .font(Font.body.bold())
            } else {
                EmptyView()
            }
        }
    }
}
