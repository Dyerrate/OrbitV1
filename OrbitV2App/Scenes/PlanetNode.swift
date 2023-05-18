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
        if let parentScene = scene as? SolarSystemScene {
            print("tapped planet in node")
            handleTap(with: parentScene.cameraNode, in: parentScene)
            
            // Pass the `name` property of the `planet` property directly
            parentScene.solarSystemDelegate?.planetSelected(planetName: planet.name, orbitName: planet.orbit.name)

        }
    }
    
    func handleTap(with cameraNode: SKCameraNode, in scene: SolarSystemScene) {
        // Toggle between zoomed-in and default state
        if !isZoomed {
            let scaleCamera = SKAction.scale(to: 0.5, duration: 0.9)
            cameraNode.run(scaleCamera)

            let followPlanet = SKAction.customAction(withDuration: 0.5) { _, elapsedTime in
                cameraNode.position = CGPoint(x: self.position.x, y: self.position.y - scene.size.height * 1/6)
            }
            cameraNode.run(followPlanet)
            scene.selectedPlanetNode = self
        } else {
            let moveCamera = SKAction.move(to: CGPoint.zero, duration: 1)
            let scaleCamera = SKAction.scale(to: 1.0, duration: 1)
            let group = SKAction.group([moveCamera, scaleCamera])
            cameraNode.run(group)
            
            scene.selectedPlanetNode = nil
        }
        
        isZoomed.toggle()
    }
}
