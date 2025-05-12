import SwiftUI
import Combine
import WatchKit
import Foundation

class PetAnimationController: ObservableObject {
    @Published var currentAsset: String = "WhiteCatIdle(Baby)1"
    
    private var sleepFrameIndex = 1
    private var idleFrameIndex = 1

    private var isDrowsy = false
    private var isSad = false
    private var isHungry = false
    private var isSleeping = false
    private var isPlayingOtherAnimation = false

    private var animationTimer: Timer?
    private var stage: PetEvolutionStage = .baby

    private enum PetMood {
        case drowsy, sad, hungry, idle
    }

    deinit {
        animationTimer?.invalidate()
    }

    private func updateStateAnimations() {
        stopCurrentAnimation()

        guard !isSleeping && !isPlayingOtherAnimation else { return }

        let currentMood: PetMood = {
            if isDrowsy { return .drowsy }
            if isSad { return .sad }
            if isHungry { return .hungry }
            return .idle
        }()

        switch currentMood {
        case .drowsy:
            startLoopedAnimation(prefix: "WhiteCatDrowsy", frameCount: 4)
        case .sad:
            startLoopedAnimation(prefix: "WhiteCatSad", frameCount: 5)
        case .hungry:
            startLoopedAnimation(prefix: "WhiteCatHungry", frameCount: 4)
        case .idle:
            startIdleAnimation()
        }
    }

    private func startLoopedAnimation(prefix: String, frameCount: Int) {
        stopCurrentAnimation()
        var frameIndex = 1
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self, !self.isSleeping, !self.isPlayingOtherAnimation else {
                self?.animationTimer?.invalidate()
                return
            }
            self.currentAsset = "\(prefix)(\(self.stage.rawValue))\(frameIndex)"
            frameIndex = (frameIndex % frameCount) + 1
        }
    }

    func updateSleepState(isSleeping: Bool, stage: PetEvolutionStage) {
        self.stage = stage
        let wasSleeping = self.isSleeping
        self.isSleeping = isSleeping

        if wasSleeping != isSleeping {
            stopCurrentAnimation()
            if isSleeping {
                startSleepAnimation()
            } else {
                updateStateAnimations()
            }
        }
    }

    private func stopCurrentAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }

    public func resetToIdle() {
        currentAsset = "WhiteCatIdle(\(stage.rawValue))1"
        idleFrameIndex = 1
    }

    func startDrowsyAnimationLoop(stage: PetEvolutionStage) {
        guard !isSleeping, !isPlayingOtherAnimation, !isDrowsy else { return }
        self.stage = stage
        isDrowsy = true
        updateStateAnimations()
    }

    func stopDrowsyAnimationLoop() {
        isDrowsy = false
        updateStateAnimations()
    }

    func startHungryAnimationLoop(stage: PetEvolutionStage) {
        guard !isSleeping, !isPlayingOtherAnimation else { return }
        self.stage = stage
        isHungry = true
        updateStateAnimations()
    }

    func stopHungryAnimationLoop() {
        isHungry = false
        updateStateAnimations()
    }

    func startSadAnimationLoop(stage: PetEvolutionStage) {
        guard !isSleeping, !isPlayingOtherAnimation else { return }
        self.stage = stage
        isSad = true
        updateStateAnimations()
    }

    func stopSadAnimationLoop() {
        isSad = false
        updateStateAnimations()
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
                timer.invalidate()
                self.isPlayingOtherAnimation = false
                self.updateStateAnimations()
            }
        }
    }
}
