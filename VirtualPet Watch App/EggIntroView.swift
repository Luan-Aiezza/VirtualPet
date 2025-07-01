import SwiftUI
import TipKit

struct EggIntroView: View {
    @AppStorage("hasSentEggHatchNotif") private var hasSentEggHatchNotif: Bool = false
    @State private var showPetView = false
    @State private var tappedEggIndex: Int? = nil
    @AppStorage("hasSeenEggIntro") private var hasSeenEggIntro: Bool = false
    
    @State private var animateEggs = false
    @State private var currentEggIndex = 0
    @State private var eggTimer: Timer?
    
    // Controle da animação de nascimento
    @State private var isHatching = false
    @State private var hatchingFrameIndex = 0
    @State private var hatchingTimer: Timer?

    let eggImages = ["Egg1", "Egg2", "Egg3", "Egg4", "Egg5", "Egg6", "Egg7", "Egg8"]
    let hatchingFrames = ["Egg_Born1", "Egg_Born2", "Egg_Born3", "Egg_Born4", "Egg_Born5"]

    var body: some View {
        ZStack {
            Image("Room")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack{
                if #available(watchOS 10.0, *) {
                    TipView(TipManager.shared.getNotificationsTip())
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 140)
            VStack {
                Spacer()
                Group {
                    if isHatching {
                        Image(hatchingFrames[hatchingFrameIndex])
                            .resizable()
                            .interpolation(.none)
                            .antialiased(false)
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                    } else {
                        Image(eggImages[currentEggIndex])
                            .resizable()
                            .interpolation(.none)
                            .antialiased(false)
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true),
                                value: animateEggs
                            )
                            .onTapGesture {
                                if tappedEggIndex == nil {
                                    tappedEggIndex = currentEggIndex
                                    startHatchingAnimation()
                                }
                            }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            
        }
        .onAppear {
            startEggIdleAnimation()
        }
        .onDisappear {
            stopEggIdleAnimation()
            stopHatchingAnimation()
        }
        .opacity(showPetView ? 0 : 1)
        .animation(.easeInOut(duration: 0.01), value: showPetView)
    }
    
    // MARK: - Egg Idle Animation
    private func startEggIdleAnimation() {
        animateEggs = true
        eggTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            currentEggIndex = (currentEggIndex + 1) % eggImages.count
        }
    }
    
    private func stopEggIdleAnimation() {
        eggTimer?.invalidate()
        eggTimer = nil
    }
    
    // MARK: - Hatching Animation
    private func startHatchingAnimation() {
        stopEggIdleAnimation()
        isHatching = true
        hatchingFrameIndex = 0

        let totalDuration: TimeInterval = 2.0
        let frameCount = hatchingFrames.count
        let frameDuration = totalDuration / Double(frameCount)

        hatchingTimer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { timer in
            if hatchingFrameIndex < frameCount - 1 {
                hatchingFrameIndex += 1
            } else {
                timer.invalidate()
                hatchingTimer = nil
                finishHatching()
            }
        }
    }
    
    private func stopHatchingAnimation() {
        hatchingTimer?.invalidate()
        hatchingTimer = nil
    }
    
    private func finishHatching() {
        withAnimation {
            hasSeenEggIntro = true
            showPetView = true
            if !hasSentEggHatchNotif {
                NotificationManager.shared.sendEggHatchedNotification()
                hasSentEggHatchNotif = true
            }
        }
    }
}

#if DEBUG
#Preview {
    EggIntroView()
}
#endif
