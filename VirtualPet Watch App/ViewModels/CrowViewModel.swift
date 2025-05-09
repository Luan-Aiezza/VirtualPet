import Foundation
import Combine
import SwiftUI
import WatchKit

class CrownViewModel: ObservableObject {
    @Published var crownValue: Double = 0.0
    
    var currentState: CrownState {
        switch Int(crownValue) {
        case 0: return .hunger
        case 1: return .sleep
        case 2: return .joy
        default: return .joy
        }
    }
}

enum CrownState {
    case hunger
    case sleep
    case joy
}
