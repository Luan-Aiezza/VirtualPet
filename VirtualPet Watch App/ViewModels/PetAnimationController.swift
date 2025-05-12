import Foundation
import SpriteKit
import Combine

class PetAnimationController: ObservableObject {
    @Published var currentScene: SKScene?

    private var petNode = SKSpriteNode(imageNamed: "WhiteCatIdle(Baby)1")
    private var animationTextures: [String: [SKTexture]] = [:]
    private var currentLoopKey: String?

    init() {
        setupScene(stage: .baby)
    }

    func setupScene(stage: PetEvolutionStage) {
        let scene = SKScene(size: CGSize(width: 184, height: 224))
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .clear

        petNode.removeAllActions()
        petNode.removeFromParent()
        petNode = SKSpriteNode(imageNamed: "WhiteCatIdle(\(stage.rawValue))1") // fallback image
        petNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        petNode.zPosition = 1
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
            "Idle": 4,
            "Feed": 8,
            "Playing": 7,
            "Sleep": 4,
            "Drowsy": 4,
            "Sad": 5,
            "Hungry": 4,
            "Denying": 3
        ]

        for (action, count) in actionsWithCounts {
            var textures: [SKTexture] = []
            for i in 1...count {
                let name = "WhiteCat\(action)(\(stage.rawValue))\(i)"
                if let image = UIImage(named: name) {
                    textures.append(SKTexture(image: image))
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

        petNode.removeAllActions()
        currentLoopKey = name

        let action = SKAction.animate(with: textures, timePerFrame: 0.15, resize: false, restore: false)
        if loop {
            petNode.run(SKAction.repeatForever(action), withKey: name)
        } else {
            petNode.run(action, withKey: name)
        }

        print("▶️ Running animation: \(name) loop: \(loop)")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.resetToIdle()
        }
    }

    func playPlaying(for stage: PetEvolutionStage) {
        runAnimation(named: "Playing", loop: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.resetToIdle()
        }
    }

    func playDenial(for stage: PetEvolutionStage) {
        runAnimation(named: "Denying", loop: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.resetToIdle()
        }
    }

    func updateSleepState(isSleeping: Bool, stage: PetEvolutionStage) {
        if isSleeping {
            runAnimation(named: "Sleep", loop: true)
        } else {
            resetToIdle()
        }
    }
}
