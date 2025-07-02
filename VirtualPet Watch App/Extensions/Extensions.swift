import Foundation
import SwiftUI
import UserNotifications
import AppIntents // se necessário para @AppStorage



private func currentLanguagePrefix() -> String {
    let preferredLanguage = Locale.preferredLanguages.first ?? "en"
    let regionCode = Locale.current.regionCode ?? "US"
    
    // Se o usuário está no Brasil, usamos o idioma como base
    if regionCode == "BR" {
        if preferredLanguage.hasPrefix("pt") {
            return "pt"
        } else if preferredLanguage.hasPrefix("es") {
            return "es"
        } else if preferredLanguage.hasPrefix("ja") || preferredLanguage.hasPrefix("jp") {
            return "jp"
        } else {
            return "en"
        }
    }
    
    // Fora do Brasil, retornar pelo idioma diretamente
    if preferredLanguage.hasPrefix("pt") {
        return "pt"
    } else if preferredLanguage.hasPrefix("es") {
        return "es"
    } else if preferredLanguage.hasPrefix("ja") || preferredLanguage.hasPrefix("jp") {
        return "jp"
    } else {
        return "en"
    }
}


// Returns the localized image asset name for a given base name
private func localizedImageName(_ base: String) -> String {
    return "\(currentLanguagePrefix())_\(base)"
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

extension PetManager {
    enum PetNeedState: String, Codable {
        case sleepy, hungry, sad, idle
    }
    
    // NOTE: Move the @AppStorage property to the main PetManager definition
    
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
                Button { [self] in
                    self.feedPet()
                    NotificationManager.shared.sendDiscoverFeaturesNotification()
                } label: {
                    Image(localizedImageName("Feed_Button"))
                }
                .buttonStyle(.borderless)
            } else {
                EmptyView()
            }
        case .sleep:
            if sleepVM.isSleeping {
                Button {
                    self.toggleSleep()
                } label: {
                    Image(localizedImageName("Awake_Button"))
                }
                .buttonStyle(.borderless)
            } else if sleepVM.canSleep() {
                Button { [self] in
                    self.toggleSleep()
                    NotificationManager.shared.sendDiscoverFeaturesNotification()
                } label: {
                    Image(localizedImageName("Sleep_Button"))
                }
                .buttonStyle(.borderless)
            } else {
                EmptyView()
            }
        case .joy:
            if !sleepVM.isSleeping && joyVM.canplay() {
                Button {
                    self.playWithPet()
                } label: {
                    Image(localizedImageName("Joy_Button"))
                }
                .buttonStyle(.borderless)
            } else {
                EmptyView()
            }
        }
    }
}
