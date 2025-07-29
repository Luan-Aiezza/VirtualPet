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
        content.title = NSLocalizedString("helloWorld", comment: "Título de ovo chocado")
        content.body = NSLocalizedString("notificationAlive", comment: "Texto de notificação de ovo chocado")
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
        content.title = NSLocalizedString("tip", comment: "Título de dica")
        content.body = NSLocalizedString("notificationNeeds", comment: "Texto de notificação de dicas")
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
    
    /// Notificação ao evoluir o pet
    func sendEvolutionNotification() {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("congratulationsTitle", comment: "Título de notificação de evolução do pet")
        content.body = NSLocalizedString("congratulationsText", comment: "Texto de notificação de evolução do pet")
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação de evolução do pet: \(error)")
            } else {
                print("Notificação de evolução do pet enviada!")
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
        case .sleepy: return NSLocalizedString("sleepyTitle", comment: "Título notificação pet com sono")
        case .hungry: return NSLocalizedString("hungryTitle", comment: "Título notificação pet com fome")
        case .sad:    return NSLocalizedString("stillTitle", comment: "Título notificação pet triste")
        }
    }
    
    var body: String {
        switch self {
        case .sleepy: return NSLocalizedString("notificationSleep", comment: "Corpo notificação pet com sono")
        case .hungry: return NSLocalizedString("notificationHungry", comment: "Corpo notificação pet com fome")
        case .sad:    return NSLocalizedString("notificationJoy", comment: "Corpo notificação pet triste")
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
