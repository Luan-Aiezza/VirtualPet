import Foundation
import TipKit

/// Gerencia o TipKit para dicas sobre como cuidar do pet.
@available(watchOS 10.0, *)
class TipManager {
    static let shared = TipManager()
    private init() {
        try? Tips.configure()
    }
    
    /// A tip que sugere usar as funções Sono e Exercício do watch.
    struct NotificationsTip: Tip {
        var title: Text {
            Text("tip")
        }
        var message: Text? {
            Text("considerNotifications")
        }
    }
    
    struct SleepExerciseTip: Tip {
        var title: Text {
            Text("tip")
        }
        var message: Text? {
            Text("tipHealth")
        }
    }
    
    /// Retorna a tip configurada para uso em views SwiftUI
    func getNotificationsTip() -> some Tip {
        NotificationsTip()
    }
    
    /// Retorna a tip sobre sono e exercício para uso em views SwiftUI
    func getSleepExerciseTip() -> some Tip {
        SleepExerciseTip()
    }
}
