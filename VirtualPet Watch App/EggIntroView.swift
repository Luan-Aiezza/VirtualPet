import SwiftUI

struct EggIntroView: View {
    /// Estado para controlar se um ovo foi tocado
    @State private var showPetView = false
    @State private var tappedEggIndex: Int? = nil
    @State private var showShineEffect = false
    @AppStorage("hasSeenEggIntro") private var hasSeenEggIntro: Bool = false
    
    // Para animação dos ovos (pode ser ajustado para aleatoriedade)
    @State private var animateEggs = false
    
    @State private var currentEggIndex = 0
    @State private var eggTimer: Timer?

    let eggImages = ["Egg1", "Egg2", "Egg3"]

    var body: some View {
        ZStack {
            Image("Room")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .padding(.bottom)

            VStack {
                Spacer()
                
                Image(eggImages[currentEggIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 80)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true),
                        value: animateEggs
                    )
                    .onTapGesture {
                        if tappedEggIndex == nil { // Só permite um toque
                            tappedEggIndex = currentEggIndex
                            withAnimation(Animation.easeOut(duration: 0.2)) {
                                showShineEffect = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                hasSeenEggIntro = true
                                showPetView = true
                            }
                        }
                    }
                    .overlay(
                        ZStack {
                            if showShineEffect && tappedEggIndex == currentEggIndex {
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.clear]), startPoint: .center, endPoint: .bottom))
                                    .frame(width: 90, height: 90)
                                    .blur(radius: 8)
                                    .transition(.scale)
                            }
                        }
                    )
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            animateEggs = true
            
            eggTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                currentEggIndex = (currentEggIndex + 1) % eggImages.count
            }
        }
        .onDisappear {
            eggTimer?.invalidate()
            eggTimer = nil
        }
        // Se showPetView for true, remove a tela de introdução (quem usa essa view deve reagir a isso)
        .opacity(showPetView ? 0 : 1)
        .animation(.easeInOut(duration: 0.3), value: showPetView)
    }
}

#if DEBUG
#Preview {
    EggIntroView()
}
#endif
