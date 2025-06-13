import Foundation
import Combine
import SwiftUI
import WatchKit

class CrownViewModel: ObservableObject {
    @Published var crownValue: Double = 0.0
    
    var currentState: CrownState {
        switch Int(crownValue) {
        case 0: return .hunger
        case 1: return .joy
        case 2: return .sleep
        default: return .joy
        }
    }

    public func incrementState() {
        if crownValue < 2 {
            crownValue += 1
        }
    }

    public func decrementState() {
        if crownValue > 0 {
            crownValue -= 1
        }
    }
}

enum CrownState {
    case hunger
    case sleep
    case joy
}
