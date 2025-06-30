import SwiftUI

struct PageIndicatorView: View {
    let currentState: CrownState

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(currentState == .hunger ? Color.white : Color.gray.opacity(0.5))
                .frame(width: 6, height: 6)
            Circle()
                .fill(currentState == .joy ? Color.white : Color.gray.opacity(0.5))
                .frame(width: 6, height: 6)
            Circle()
                .fill(currentState == .sleep ? Color.white : Color.gray.opacity(0.5))
                .frame(width: 6, height: 6)
        }.padding(.trailing, 10)
    }
}
