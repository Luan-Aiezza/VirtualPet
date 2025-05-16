import SwiftUI
import Combine
import WatchKit
import Foundation

class HungerViewModel: ObservableObject {
    @Published var hunger: Double = 25.0
    
    
    func update(interval: TimeInterval) {
        let decay = interval / (0.012 * 3600) * 100
        hunger = max(0, hunger - decay)
    }

    func feed() {
        hunger = 100.0
    }

    func canFeed() -> Bool {
        hunger < 25.0 // 2.5 de margem
    }
}
