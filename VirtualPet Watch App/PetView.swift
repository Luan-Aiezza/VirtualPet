import SwiftUI
import Combine
import WatchKit
import SpriteKit
import TipKit

private func localizedHatchButtonImageName() -> String {
    let preferredLanguage = Locale.preferredLanguages.first ?? "en"
    let regionCode = Locale.current.regionCode ?? "US"

    if regionCode == "BR" {
        if preferredLanguage.hasPrefix("pt") {
            return "pt_Hatch_Button"
        } else if preferredLanguage.hasPrefix("es") {
            return "es_Hatch_Button"
        } else if preferredLanguage.hasPrefix("ja") || preferredLanguage.hasPrefix("jp") {
            return "jp_Hatch_Button"
        } else {
            return "en_Hatch_Button"
        }
    }
    if preferredLanguage.hasPrefix("pt") {
        return "pt_Hatch_Button"
    } else if preferredLanguage.hasPrefix("es") {
        return "es_Hatch_Button"
    } else if preferredLanguage.hasPrefix("ja") || preferredLanguage.hasPrefix("jp") {
        return "jp_Hatch_Button"
    } else {
        return "en_Hatch_Button"
    }
}

struct ContentView: View {
    @StateObject private var petManager = PetManager()
    @AppStorage("hasSeenEggIntro") private var hasSeenEggIntro: Bool = false
    @State private var introDismissed = false
    
    var body: some View {
        if !hasSeenEggIntro && !introDismissed {
            EggIntroView()
                .transition(.opacity)
                .zIndex(10)
                .onChange(of: hasSeenEggIntro) { newValue in
                    if newValue { introDismissed = true }
                }
        } else {
            // MARK: - Show Dead Image if pet is dead
            if petManager.lifeManager.isDead {
                ZStack{
                    Image("Room")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        Button(action: {
                            // TODO: You must implement petManager.resetAll() to correctly reset the pet/game state.
                            petManager.resetAll()
                            hasSeenEggIntro = false
                            introDismissed = false
                        }) {
                            Image(localizedHatchButtonImageName())
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 100, maxHeight: 44)
                        }
                        .buttonStyle(.borderless)
                        Image("Dead")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 120, maxHeight: 120)
                        Text("petDied")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            } else {
                // MARK: - Normal pet interface when pet is alive
                ZStack(alignment: .leading) {
                    ZStack(alignment: .topTrailing) {
                        // Needs Icons, only when alive
                        PetNeedsIconsView(
                            showFeed: petManager.hungerVM.canFeed(),
                            showJoy: petManager.joyVM.canplay(),
                            showSleep: petManager.sleepVM.canSleep()
                        )
                        
                        GeometryReader { geo in
                            
                            //Chamada da barra de status
                            progressBarForCurrentState(width: geo.size.width * 0.15)
                            
                            //Escurecimento caso o pet esteja dormindo
                            if petManager.sleepVM.isSleeping {
                                Color.black.opacity(0.6) // ajuste a opacidade conforme quiser
                                    .ignoresSafeArea()
                                    .transition(.opacity)
                                    .animation(.easeInOut, value: petManager.sleepVM.isSleeping)
                            }
                            VStack {
                                Spacer()
                                //Pet
                                SpriteView(scene: petManager.animationController.currentScene!)
                                    .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                                        petManager.updateState()
                                    }
                                Spacer()
                            }
                            .ignoresSafeArea()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear {
                                petManager.startTimer()
                            }
                            .onDisappear {
                                petManager.stopTimer()
                            }
                            
                            //Botões
                            VStack{
                                //Indicator para em que estado o usuario está
                                PageIndicatorView(
                                    currentState: petManager.crownVM.currentState,
                                    sleepLevel: petManager.sleepVM.sleep,
                                    hungerLevel: petManager.hungerVM.hunger,
                                    joyLevel: petManager.joyVM.joy
                                )
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 30)
                                Spacer()
                                petManager.handleCrownValueButton()
                                    .frame(width: geo.size.width/2.2, height: geo.size.height/2.5)
                            }
                            .ignoresSafeArea()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    //Background
                    .background(
                        Image(backgroundImage(for: petManager.crownVM.currentState))
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .padding(.bottom)
                    )
                    //Tip
                    VStack{
                        if #available(watchOS 10.0, *) {
                            TipView(TipManager.shared.getSleepExerciseTip())
                                .padding(.horizontal)
                        }
                    }.padding(.bottom, 140)
                }
                .allowsHitTesting(!petManager.lifeManager.isDead)
                // Movimentacão via gesture
                .gesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onEnded { value in
                            if value.translation.width < 0 {
                                // Swipe up
                                petManager.crownVM.incrementState()
                            } else if value.translation.width > 0 {
                                // Swipe down
                                petManager.crownVM.decrementState()
                            }
                        }
                )
            }
        }
    }
    
    // MARK: - Helper: barra de progresso baseada no estado atual da coroa
    @ViewBuilder
    private func progressBarForCurrentState(width: CGFloat) -> some View {
        switch petManager.crownVM.currentState {
        case .hunger:
            ProgressBar(value: petManager.hungerVM.hunger, color: .yellow, iconName: "Feed_Icon")
                .frame(width: width)
            
        case .joy:
            ProgressBar(value: petManager.joyVM.joy, color: .green, iconName: "Joy_Icon")
                .frame(width: width)
            
        case .sleep:
            ProgressBar(value: petManager.sleepVM.sleep, color: .cyan, iconName: "Sleep_Icon")
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
