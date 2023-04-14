//
//  SolarSystemScene.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/8/23.
//

import SpriteKit

class SolarSystemScene: SKScene {
    private var planetNode1: PlanetNode!
    private var planetNode2: PlanetNode!
    private var planetNode3: PlanetNode!
    private var sun: SKSpriteNode!
    private var ring: SKSpriteNode!
    var cameraNode: SKCameraNode!
    private var lastTouchLocation: CGPoint?
    private var initialCameraScale: CGFloat = 1.0
    var selectedPlanetNode: PlanetNode?

    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        
        let width: CGFloat = size.width / 2
        let height: CGFloat = size.height / 2
        let center = CGPoint(x:0, y: 0)
        let rotationAngle = -45 * CGFloat.pi / 180
        
        sun = SKSpriteNode(imageNamed: "sun1")
        sun.position = CGPoint(x:0, y: 0)
        sun.xScale = 0.008
        sun.yScale = 0.008
        addChild(sun)
        
        let orbit1 = OrbitNode(width: width, height: height, center: center, rotationAngle: rotationAngle, strokeColor: .white)
        addChild(orbit1)
        
        let orbit2 = OrbitNode(width: width / 1.5, height: height / 1.5, center: center, rotationAngle: rotationAngle, strokeColor: .white)
        addChild(orbit2)
        
        let orbit3 = OrbitNode(width: width / 3.5, height: height / 3.5, center: center, rotationAngle: rotationAngle, strokeColor: .white)
        addChild(orbit3)
        
        // Add planetNode1
        planetNode1 = PlanetNode(planet: Planet(name: "planet1", imageName: "planet1"), imageNamed: "planet1", view: view)
        planetNode1.xScale = 0.01
        planetNode1.yScale = 0.01
        addChild(planetNode1)
        
        // Add planetNode2
        planetNode2 = PlanetNode(planet: Planet(name: "planet2", imageName: "planet2"), imageNamed: "planet2", view: view)
        planetNode2.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        planetNode2.xScale = 0.01
        planetNode2.yScale = 0.01
        addChild(planetNode2)
        
        // Add planetNode3
        planetNode3 = PlanetNode(planet: Planet(name: "planet3", imageName: "planet3"), imageNamed: "planet3", view: view)
        planetNode3.position = CGPoint(x: size.width / 2 + 100, y: size.height / 2)
        planetNode3.xScale = 0.01
        planetNode3.yScale = 0.01
        addChild(planetNode3)
        
        // Create actions to make the planets follow the oval paths
        let followPath1 = SKAction.follow(orbit1.path!, asOffset: false, orientToPath: false, duration: 60)
        let followPath2 = SKAction.follow(orbit2.path!, asOffset: false, orientToPath: false, duration: 69)
        let followPath3 = SKAction.follow(orbit3.path!, asOffset: false, orientToPath: false, duration: 78)
        
        let repeatForever1 = SKAction.repeatForever(followPath1)
        let repeatForever2 = SKAction.repeatForever(followPath2)
        let repeatForever3 = SKAction.repeatForever(followPath3)
        
        planetNode1.run(repeatForever1)
        planetNode2.run(repeatForever2)
        planetNode3.run(repeatForever3)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        if let planetNode = touchedNode as? PlanetNode {
            planetNode.handleTap(with: cameraNode, in: self)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        if let lastTouchLocation = lastTouchLocation {
            let dx = location.x - lastTouchLocation.x
            let dy = location.y - lastTouchLocation.y
            cameraNode.position = CGPoint(x: cameraNode.position.x - dx, y: cameraNode.position.y - dy)
        }
        
        self.lastTouchLocation = previousLocation
    }
//When the user stops touching lol
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchLocation = nil
    }

    //for using two fingers to zoom
    @objc func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began {
            initialCameraScale = cameraNode.xScale
        }
        
        if gestureRecognizer.state == .changed {
            let newScale = initialCameraScale / gestureRecognizer.scale
            cameraNode.setScale(newScale)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if let selectedPlanetNode = selectedPlanetNode {
            cameraNode.position = selectedPlanetNode.position
        }
    }
}
