import Foundation

struct PetState: Codable {
    let sleepLevel: Double
    let joyLevel: Double
    let isSleeping: Bool
    let hungerLevel: Double
    let isDead: Bool
    let currentAsset: String
    let lastActionTime: Date
    let timeOfDeathStart: Date?
    let crownValue: Double
    let evolutionStage: PetEvolutionStage
    let birthDate: Date
}
