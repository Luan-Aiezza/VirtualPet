import SwiftUI

struct PageIndicatorView: View {
    let currentState: CrownState
    let sleepLevel: Double
    let hungerLevel: Double
    let joyLevel: Double
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(currentState == .hunger ? Color.white : Color.gray.opacity(0.5))
                .frame(width: 8, height: 8)
            
            Circle()
                .fill(currentState == .joy ? Color.white : Color.gray.opacity(0.5))
                .frame(width: 8, height: 8)
            
            Circle()
                .fill(currentState == .sleep ? Color.white : Color.gray.opacity(0.5))
                .frame(width: 8, height: 8)
            
        }
    }
}
