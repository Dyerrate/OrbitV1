//
//  SolarSystemScene.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/8/23.
//

import SpriteKit

class SolarSystemScene: SKScene {
    weak var solarSystemDelegate: SolarSystemSceneDelegate?
    private var sun: SKSpriteNode!
    private var ring: SKSpriteNode!
    var cameraNode: SKCameraNode!
    private var lastTouchLocation: CGPoint?
    private var initialCameraScale: CGFloat = 1.0
    var selectedPlanetNode: PlanetNode?
    
    var user: User?
    var planetOrbitDictionary: [Planet: Orbit] = [:]

    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        
//KEEP FOR NOW
        let width: CGFloat = size.width / 2
        let height: CGFloat = size.height / 2
        
        let center = CGPoint(x:0, y: 0)
        let rotationAngle = -45 * CGFloat.pi / 180
        var orbitDuration: Double = 60
        var positions: Double = 0

        sun = SKSpriteNode(imageNamed: "sun1")
        sun.position = CGPoint(x:0, y: 0)
        sun.xScale = 0.008
        sun.yScale = 0.008
        addChild(sun)
        for (planet, orbit) in planetOrbitDictionary {
                let orbitNode = OrbitNode(orbit: orbit, center: center, rotationAngle: rotationAngle, strokeColor: .white)
                addChild(orbitNode)

            let planetNode = PlanetNode(planet: planet, imageNamed: planet.image!, view: view)
                planetNode.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
                planetNode.xScale = 0.01
                planetNode.yScale = 0.01
                addChild(planetNode)

                let followPath = SKAction.follow(orbitNode.path!, asOffset: false, orientToPath: false, duration: orbitDuration)
                orbitDuration = orbitDuration * 2
                let repeatForever = SKAction.repeatForever(followPath)
                planetNode.run(repeatForever)
            }
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        if let planetNode = touchedNode as? PlanetNode {
            print("Tapped on a planet from scene")
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
            cameraNode.position = CGPoint(x: selectedPlanetNode.position.x, y: selectedPlanetNode.position.y - size.height * 1/6)
        }
    }
}
