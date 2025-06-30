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
            Text("Tip!")
        }
        var message: Text? {
            Text("Consider enabling notifications to help take care of your pet!")
        }
    }
    
    struct SleepExerciseTip: Tip {
        var title: Text {
            Text("Tip!")
        }
        var message: Text? {
            Text("In addition to the buttons, you can satisfy your pet's needs through sleep mode and exercising with the Watch!")
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
