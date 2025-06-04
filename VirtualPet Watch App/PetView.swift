import SwiftUI
import Combine
import WatchKit
import SpriteKit

struct ContentView: View {
    @StateObject private var petManager = PetManager()
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            GeometryReader { geo in
                
                progressBarForCurrentState(width: geo.size.width * 0.15)
                
                VStack {
                    Spacer()
                    SpriteView(scene: petManager.animationController.currentScene!)
                        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                            petManager.updateState()
                        }
                    Spacer()
                }
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .focusable()
                .digitalCrownRotation($petManager.crownVM.crownValue,
                                      from: 0,
                                      through: 2,
                                      by: 1.0,
                                      sensitivity: .low)
                .onAppear {
                    petManager.startTimer()
                }
                .onDisappear {
                    petManager.stopTimer()
                }
                
                VStack{
                    Spacer()
                    petManager.handleCrownValueButton()
                        .frame(width: geo.size.width/2.2, height: geo.size.height/2.5)
                }
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            .background(
                Image(backgroundImage(for: petManager.crownVM.currentState))
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .padding(.bottom)
            )
            
        }
    }
    
    // MARK: - Helper: barra de progresso baseada no estado atual da coroa
    @ViewBuilder
    private func progressBarForCurrentState(width: CGFloat) -> some View {
        switch petManager.crownVM.currentState {
        case .hunger:
            ProgressBar(value: petManager.hungerVM.hunger, color: .yellow)
                .frame(width: width)

        case .joy:
            ProgressBar(value: petManager.joyVM.joy, color: .green)
                .frame(width: width)
            
        case .sleep:
            ProgressBar(value: petManager.sleepVM.sleep, color: .indigo)
                .frame(width: width)
        }
    }
    
    func backgroundImage(for state: CrownState) -> String {
        switch state {
        case .hunger: return "Kitchen"
        case .sleep: return "Bedroom"
        case .joy: return "Room"
        }
    }
    
}

struct ProgressBar: View {
    var value: Double  // Esperado entre 0.0 e 1.0
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Barra de fundo (limite total)
                RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                // Barra de progresso proporcional
                RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height * CGFloat(clamp(value/100))
                    )
                    .foregroundColor(color)
            }
        }
        .padding(.horizontal)
    }
    
    private func clamp(_ value: Double) -> Double {
        return min(max(value, 0.0), 1.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
