import SwiftUI
import Combine
import WatchKit
import Foundation

class JoyViewModel: ObservableObject {
    @Published var joy: Double = 25.0

    func update(interval: TimeInterval) {
        joy = max(0, joy - interval / (0.024 * 3600) * 100)
    }

    func play() {
        joy = 100.0
    }
    
    func canplay() -> Bool {
        joy < 25.0 // 2.5 de margem
    }
}
