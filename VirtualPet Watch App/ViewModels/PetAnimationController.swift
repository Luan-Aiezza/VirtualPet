import Foundation
import SpriteKit
import Combine

class PetAnimationController: ObservableObject {
    @Published var currentScene: SKScene?
    
    private var isBusyWithTemporaryAnimation = false
    private var petNode = SKSpriteNode(imageNamed: "WhiteCatIdle(Baby)1")
    private var animationTextures: [String: [SKTexture]] = [:]
    private var currentLoopKey: String?

    private let frameRates: [String: Double] = [
        "Idle": 0.15,
        "Feed": 0.2,
        "Playing": 0.1,
        "Sleep": 0.2,
        "Drowsy": 0.2,
        "Sad": 0.25,
        "Hungry": 0.25,
        "Denying": 0.3
    ]

    init() {
        setupScene(stage: .baby)
    }

    func setupScene(stage: PetEvolutionStage) {
        let scene = SKScene(size: CGSize(width: 184, height: 224))
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .clear

        petNode.removeAllActions()
        petNode.removeFromParent()
        petNode = SKSpriteNode(imageNamed: "WhiteCatIdle(\(stage.rawValue))1")
        petNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        petNode.zPosition = 1
        petNode.texture?.filteringMode = .nearest
        petNode.setScale(1.5)
        petNode.alpha = 1.0
        petNode.isHidden = false

        scene.addChild(petNode)
        currentScene = scene

        preloadAnimations(for: stage)

        print("✅ Scene initialized for stage \(stage.rawValue)")
        print("🐾 PetNode position: \(petNode.position), alpha: \(petNode.alpha), hidden: \(petNode.isHidden)")
    }

    private func preloadAnimations(for stage: PetEvolutionStage) {
        let actionsWithCounts: [String: Int] = [
            "Idle": 2,
            "Feed": 8,
            "Playing": 7,
            "Sleep": 4,
            "Drowsy": 3,
            "Sad": 5,
            "Hungry": 4,
            "Denying": 3
        ]

        for (action, count) in actionsWithCounts {
            var textures: [SKTexture] = []
            for i in 1...count {
                let name = "WhiteCat\(action)(\(stage.rawValue))\(i)"
                if let image = UIImage(named: name) {
                    let texture = SKTexture(image: image)
                    texture.filteringMode = .nearest
                    textures.append(texture)
                } else {
                    print("⚠️ Missing texture: \(name)")
                }
            }
            animationTextures[action] = textures
        }
    }

    private func runAnimation(named name: String, loop: Bool = true) {
        guard let textures = animationTextures[name], !textures.isEmpty else {
            print("⚠️ No textures for animation: \(name)")
            return
        }

        if isBusyWithTemporaryAnimation && loop {
            print("⏸ Ignoring loop animation \(name) because a temporary animation is active.")
            return
        }

        petNode.removeAllActions()
        currentLoopKey = name

        let timePerFrame = frameRates[name] ?? 0.3
        let action = SKAction.animate(with: textures, timePerFrame: timePerFrame)

        if loop {
            petNode.run(SKAction.repeatForever(action), withKey: name)
        } else {
            isBusyWithTemporaryAnimation = true
            let completion = SKAction.run { [weak self] in
                self?.isBusyWithTemporaryAnimation = false
                self?.resetToIdle()
            }
            let sequence = SKAction.sequence([action, completion])
            petNode.run(sequence, withKey: name)
        }

        print("▶️ Running animation: \(name) | loop: \(loop) | timePerFrame: \(timePerFrame)")
    }

    func resetToIdle() {
        runAnimation(named: "Idle", loop: true)
    }

    func startIdleAnimation(stage: PetEvolutionStage) {
        runAnimation(named: "Idle", loop: true)
    }

    func startDrowsyAnimationLoop(stage: PetEvolutionStage) {
        runAnimation(named: "Drowsy", loop: true)
    }

    func startHungryAnimationLoop(stage: PetEvolutionStage) {
        runAnimation(named: "Hungry", loop: true)
    }

    func startSadAnimationLoop(stage: PetEvolutionStage) {
        runAnimation(named: "Sad", loop: true)
    }

    func playFeeding(for stage: PetEvolutionStage) {
        runAnimation(named: "Feed", loop: false)
    }

    func playPlaying(for stage: PetEvolutionStage) {
        runAnimation(named: "Playing", loop: false)
    }

    func playDenial(for stage: PetEvolutionStage) {
        runAnimation(named: "Denying", loop: false)
    }

    func updateSleepState(isSleeping: Bool, stage: PetEvolutionStage) {
        if isSleeping {
            runAnimation(named: "Sleep", loop: true)
        } else {
            resetToIdle()
        }
    }
}
