//
//  PlanetNode.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/9/23.
//

import SpriteKit

class PlanetNode: SKSpriteNode {
    private let planet: Planet
    private weak var view: UIView?
    private var isZoomed = false

    init(planet: Planet, imageNamed: String, view: UIView) {
        self.planet = planet
        self.view = view
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: .clear, size: texture.size())
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let parentScene = scene as? SolarSystemScene, let touch = touches.first {
            let locationInScene = touch.location(in: parentScene)
            print("tapped planet in node")
            print("tapped location: \(locationInScene)")
            handleTap(with: parentScene.cameraNode, in: parentScene)
        }
        super.touchesBegan(touches, with: event)
        if let scene = self.scene as? SolarSystemScene {
            scene.handlePlanetTapped(planetInfo: self.planet)
        }
    }
    
    func handleTap(with cameraNode: SKCameraNode, in scene: SolarSystemScene) {
        // Toggle between zoomed-in and default state
        if !isZoomed {
            let scaleCamera = SKAction.scale(to: 0.5, duration: 0.9)
            cameraNode.run(scaleCamera)
            scene.selectedPlanetNode = self
            scene.shouldFollowPlanet = true
        } else {
            let moveCamera = SKAction.move(to: CGPoint(x: scene.size.width / 2, y: scene.size.height / 2), duration: 1)
            let scaleCamera = SKAction.scale(to: scene.size.width / scene.size.height, duration: 1)
            let group = SKAction.group([moveCamera, scaleCamera])
            cameraNode.run(group)
            scene.selectedPlanetNode = nil
            scene.shouldFollowPlanet = false
        }
        scene.toggleHUDLabelsVisibility()
        isZoomed.toggle()
    }
}
