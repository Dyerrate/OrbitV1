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
    let inclinationAngle: CGFloat = -35 * CGFloat.pi / 180
    var user: User?
    var planetOrbitDictionary: [Planet: Orbit] = [:]

    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        let center = CGPoint(x:0, y: 0)
        var orbitDuration: Double = 60
        sun = SKSpriteNode(imageNamed: "sun1")
        sun.position = CGPoint(x:0, y: 0)
        sun.xScale = 0.008
        sun.yScale = 0.008
        addChild(sun)
        for (planet, orbit) in planetOrbitDictionary {
            let orbitNode = OrbitNode(orbit: orbit, center: center, strokeColor: .white)
            orbitNode.zRotation = inclinationAngle
            addChild(orbitNode)
            
            let planetNode = PlanetNode(planet: planet, imageNamed: planet.image!, view: view)
            let orbitPath = orbitNode.getOrbitPath().rotatedPath(by: orbitNode.orbitRotation)
            let initialPosition = pointOnPath(path: orbitPath, atPercentOfLength: 0.0)
            planetNode.position = initialPosition
            planetNode.xScale = 0.01
            planetNode.yScale = 0.01
            addChild(planetNode)

            let followPath = SKAction.follow(orbitPath, asOffset: false, orientToPath: false, duration: orbitDuration)
            let repeatForever = SKAction.repeatForever(followPath)
            planetNode.run(repeatForever)
            
            orbitDuration = orbitDuration * 2
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
    func pointOnPath(path: CGPath, atPercentOfLength percent: CGFloat) -> CGPoint {
        let t = min(max(percent, 0), 1)
        return pointAtPercentOfPath(path: path, percent: t)
    }

    func pointAtPercentOfPath(path: CGPath, percent: CGFloat) -> CGPoint {
        var point = CGPoint.zero
        var previousPoint = CGPoint.zero
        var totalLength: CGFloat = 0
        var lengths: [CGFloat] = []

        path.applyWithBlock { elementPointer in
            let element = elementPointer.pointee
            switch element.type {
            case .moveToPoint:
                previousPoint = element.points[0]
            case .addLineToPoint:
                let currentPoint = element.points[0]
                let distance = hypot(currentPoint.x - previousPoint.x, currentPoint.y - previousPoint.y)
                totalLength += distance
                lengths.append(totalLength)
                previousPoint = currentPoint
            default:
                break
            }
        }

        let targetLength = percent * totalLength
        var index = 0
        while index < lengths.count && lengths[index] < targetLength {
            index += 1
        }

        if index == 0 {
            point = path.currentPoint
        } else {
            let currentPoint = path.currentPoint
            let remainingLength = targetLength - lengths[index - 1]
            let totalSegmentLength = lengths[index] - lengths[index - 1]
            let t = remainingLength / totalSegmentLength
            point.x = previousPoint.x + (currentPoint.x - previousPoint.x) * t
            point.y = previousPoint.y + (currentPoint.y - previousPoint.y) * t
        }

        return point
    }
}

