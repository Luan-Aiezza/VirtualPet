import SwiftUI
import Combine
import WatchKit
import Foundation

class PetAnimationController: ObservableObject {
    @Published var currentAsset: String = "WhiteCatIdle(Baby)1"
    
    private var sleepFrameIndex = 1
    private var idleFrameIndex = 1
    private var isSleeping = false
    private var isPlayingOtherAnimation = false
    private var stage: PetEvolutionStage = .baby
    private var animationTimer: Timer?

    
    deinit {
        animationTimer?.invalidate()
    }
    
    func updateSleepState(isSleeping: Bool, stage: PetEvolutionStage) {
        self.stage = stage
        let wasSleeping = self.isSleeping
        self.isSleeping = isSleeping
        
        // Se o estado mudou, reinicie a animação apropriada
        if wasSleeping != isSleeping {
            stopCurrentAnimation()
            
            if isSleeping {
                startSleepAnimation()
            } else {
                resetToIdle()
                startIdleAnimation()
            }
        }
    }
    
    private func stopCurrentAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func resetToIdle() {
        currentAsset = "WhiteCatIdle(\(stage.rawValue))1"
        idleFrameIndex = 1
    }
    
    public func startSleepAnimation() {
        guard isSleeping && !isPlayingOtherAnimation else { return }
        
        stopCurrentAnimation()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self, self.isSleeping, !self.isPlayingOtherAnimation else {
                self?.animationTimer?.invalidate()
                return
            }
            
            self.currentAsset = "WhiteCatSleep(\(self.stage.rawValue))\(self.sleepFrameIndex)"
            self.sleepFrameIndex = (self.sleepFrameIndex % 4) + 1
        }
    }
    
    public func startIdleAnimation() {
        guard !isSleeping && !isPlayingOtherAnimation else { return }
        
        stopCurrentAnimation()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            guard let self = self, !self.isSleeping, !self.isPlayingOtherAnimation else {
                self?.animationTimer?.invalidate()
                return
            }
            
            let nextFrameIndex = (self.idleFrameIndex == 1) ? 2 : 1
            self.currentAsset = "WhiteCatIdle(\(self.stage.rawValue))\(self.idleFrameIndex)"
            self.idleFrameIndex = nextFrameIndex
        }
    }
    
    func playFeeding(for stage: PetEvolutionStage) {
        playTemporaryAnimation(animationName: "Feed", frameCount: 8, stage: stage)
    }
    
    func playPlaying(for stage: PetEvolutionStage) {
        playTemporaryAnimation(animationName: "Playing", frameCount: 7, stage: stage)
    }
    
    func playDenial(for stage: PetEvolutionStage) {
        playTemporaryAnimation(animationName: "Denying", frameCount: 3, stage: stage)
    }
    
    private func playTemporaryAnimation(animationName: String, frameCount: Int, stage: PetEvolutionStage) {
        isSleeping = false
        isPlayingOtherAnimation = true
        stopCurrentAnimation()
        
        var currentFrameIndex = 1
        let frames = (1...frameCount).map { "WhiteCat\(animationName)(\(stage.rawValue))\($0)" }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if currentFrameIndex <= frameCount {
                self.currentAsset = frames[currentFrameIndex - 1]
                currentFrameIndex += 1
            } else {
                // Animação concluída
                timer.invalidate()
                self.isPlayingOtherAnimation = false
                self.resetToIdle()
                self.startIdleAnimation()
            }
        }
    }
}
