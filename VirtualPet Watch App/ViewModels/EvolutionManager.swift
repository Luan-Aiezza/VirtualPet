import SwiftUI
import Combine
import WatchKit
import Foundation

class EvolutionManager: ObservableObject {
    @Published var stage: PetEvolutionStage = .baby

    func updateStage(birthDate: Date) {
        let months = Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0 //MUDAR PARA MES DEPOIS DOS TESTES
        if months >= 3 {
            stage = .adult
        } else if months >= 2 {
            stage = .children
        } else {
            stage = .baby
        }
    }
}
