import SwiftUI
import Combine
import WatchKit
import Foundation

class EvolutionManager: ObservableObject {
    @Published var stage: PetEvolutionStage = .baby

    func updateStage(birthDate: Date) {
        let months = Calendar.current.dateComponents([.month], from: birthDate, to: Date()).month ?? 0
        if months >= 4 {
            stage = .adult
        } else if months >= 1 {
            stage = .children
        } else {
            stage = .baby
        }
    }
}
