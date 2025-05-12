enum PetEvolutionStage: String, Codable {
    case baby = "Baby"
    case children = "Children"
    case adult = "Adult"

    var intValue: Int {
        switch self {
        case .baby: return 0
        case .children: return 1
        case .adult: return 2
        }
    }
}

