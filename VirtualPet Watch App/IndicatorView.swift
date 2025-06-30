import SwiftUI

struct PageIndicatorView: View {
    let currentState: CrownState
    let sleepLevel: Double
    let hungerLevel: Double
    let joyLevel: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 2) {
                if hungerLevel < 25 {
                    Image("Feed_Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 6, height: 6)
                }
                Spacer(minLength: 0)
                Circle()
                    .fill(currentState == .hunger ? Color.white : Color.gray.opacity(0.5))
                    .frame(width: 6, height: 6)
            }
            .frame(width: 16, alignment: .trailing)
            
            HStack(spacing: 2) {
                if joyLevel < 25 {
                    Image("Joy_Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 6, height: 6)
                }
                Spacer(minLength: 0)
                Circle()
                    .fill(currentState == .joy ? Color.white : Color.gray.opacity(0.5))
                    .frame(width: 6, height: 6)
            }
            .frame(width: 16, alignment: .trailing)
            
            HStack(spacing: 2) {
                if sleepLevel < 25 {
                    Image("Sleep_Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 6, height: 6)
                }
                Spacer(minLength: 0)
                Circle()
                    .fill(currentState == .sleep ? Color.white : Color.gray.opacity(0.5))
                    .frame(width: 6, height: 6)
            }
            .frame(width: 16, alignment: .trailing)
        }
        .padding(.trailing, 10)
    }
}
