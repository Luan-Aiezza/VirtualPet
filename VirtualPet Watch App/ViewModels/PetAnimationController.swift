import SwiftUI
import Combine
import WatchKit
import Foundation

class PetAnimationController: ObservableObject {
    @Published var currentAsset: String = "WhiteCatIdle(Baby)1"

    func playFeeding(for stage: PetEvolutionStage) {
        animate(sequence: (1...8).map { "WhiteCatFeed(\(stage.rawValue))\($0)" })
    }

    func playPlaying(for stage: PetEvolutionStage) {
        animate(sequence: (1...7).map { "WhiteCatPlaying(\(stage.rawValue))\($0)" })
    }

    func playDenial(for stage: PetEvolutionStage) {
        animate(sequence: (1...3).map { "WhiteCatDenying(\(stage.rawValue))\($0)" })
    }

    func updateSleepState(isSleeping: Bool, stage: PetEvolutionStage) {
        currentAsset = isSleeping ? "WhiteCatSleep(\(stage.rawValue))1" : "WhiteCatIdle(\(stage.rawValue))1"
    }
    

    private func animate(sequence: [String], delay: Double = 0.3) {
        for (index, frame) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * delay) {
                self.currentAsset = frame
            }
        }
    }
}
