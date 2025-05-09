import SwiftUI
import Combine
import WatchKit

struct ContentView: View {
    @StateObject private var petManager = PetManager()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Barra lateral à esquerda (por exemplo, barra de fome)
                // Aqui você pode manter o ProgressBar conforme necessário:
                ProgressBar(value: petManager.hungerVM.hunger, color: .green)
                    .frame(width: geo.size.width / 7)

                HStack(spacing: 0) {
                    VStack {
                        Spacer()

                        // Exibe a imagem do pet, de preferência controlada pelo seu animationController
                        Image(petManager.animationController.currentAsset)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: geo.size.height * 0.6)
                            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                                // Atualize estados do pet conforme a lógica do PetManager
                                petManager.updateState()
                            }
                        
                        petManager.handleCrownValueButton()
                            .padding(.bottom)

                        Spacer()

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
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
            }
            .background(
                Image(backgroundImage(for: petManager.crownVM.currentState))
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .padding(.bottom, 40)
            )
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
    var value: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
                    .frame(
                        width: geometry.size.width,
                        // Por exemplo, ajustando a altura proporcionalmente
                        height: max(0, min(CGFloat(value) * geometry.size.width/4.75, geometry.size.height))
                    )
                    .foregroundColor(color)
            }
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
