import SwiftUI
import Combine
import WatchKit
import Foundation

class JoyViewModel: ObservableObject {
    @Published var joy: Double = 30.0

    func update(interval: TimeInterval) {
        joy = max(0, joy - interval / (24 * 3600) * 100)
    }

    func play() {
        joy = 100.0
    }
}
