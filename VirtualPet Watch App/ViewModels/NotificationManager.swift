import UserNotifications
import Foundation


class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Erro ao solicitar permissão de notificação: \(error)")
            } else if granted {
                print("Permissão de notificação concedida.")
            } else {
                print("Permissão de notificação negada.")
            }
        }
    }
    
    /// Envia uma notificação para o pet com o tipo e estágio fornecidos.
    /// Exemplo de uso:
    /// NotificationManager.shared.sendPetNotification(type: .sleepy(stage: .baby), stage: .baby)
    func sendPetNotification(type: PetNotificationType, stage: PetEvolutionStage) {
        let content = UNMutableNotificationContent()
        content.title = type.title
        content.body = type.body
        content.sound = .default
        
        // Tente adicionar um attachment se houver
        // O nome do asset deve estar no Assets.xcassets conforme padrão:
        // WhiteCatDrowsy(baby)1, WhiteCatDrowsy(children)1, WhiteCatDrowsy(adult)1, etc.
        if let assetName = type.assetName(stage: stage),
           let url = Bundle.main.url(forResource: assetName, withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: assetName, url: url, options: nil) {
                content.attachments = [attachment]
            }
        }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error)")
            } else {
                print("Notificação enviada: \(type) no estágio: \(stage.rawValue)")
            }
        }
    }
    
    /// Notificação ao chocar o ovo
    func sendEggHatchedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hello World!!!"
        content.body = "It's so good to be alive, human!/ᐠ - ˕ -マ Ⳋ"
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação de nascimento do pet: \(error)")
            } else {
                print("Notificação de nascimento do pet enviada!")
            }
        }
    }
    
    /// Notificação ao primeiro clique em sleep/feed
    func sendDiscoverFeaturesNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Tip!"
        content.body = "You can also use sleep and workout mode to satisfy my needs!❤️"
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação de dicas: \(error)")
            } else {
                print("Notificação de dicas enviada!")
            }
        }
    }
}

/// Notificação do pet com tipo e estágio associados.
/// O estágio representa a evolução do pet (baby, children, adult).
enum PetNotificationType {
    case sleepy(stage: PetEvolutionStage)
    case hungry(stage: PetEvolutionStage)
    case sad(stage: PetEvolutionStage)
    
    var title: String {
        switch self {
        case .sleepy: return "Your pet is sleepy!"
        case .hungry: return "Your pet is hungry!"
        case .sad:    return "Your pet is very still!"
        }
    }
    
    var body: String {
        switch self {
        case .sleepy: return "It's time for us to go to sleep, my human! 😴"
        case .hungry: return "I'm soooo hungry human! 🍖"
        case .sad:    return "I'm very very bored, human! 🧸"
        }
    }
    
    /// Gera dinamicamente o nome do asset da imagem para o tipo e estágio.
    /// O nome deve seguir o padrão em Assets.xcassets:
    /// WhiteCatDrowsy(baby)1, WhiteCatDrowsy(children)1, WhiteCatDrowsy(adult)1, etc.
    func assetName(stage: PetEvolutionStage) -> String? {
        switch self {
        case .sleepy:
            return "WhiteCatDrowsy(\(stage.rawValue))1"
        case .hungry:
            return "WhiteCatHungry(\(stage.rawValue))1"
        case .sad:
            return "WhiteCatSad(\(stage.rawValue))1"
        }
    }
}
