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
    let initialOrbitSize: CGFloat = 100
    private var lastTouchLocation: CGPoint?
    private var initialCameraScale: CGFloat = 1.0
    var selectedPlanetNode: PlanetNode?
    let inclinationAngle: CGFloat = -35 * CGFloat.pi / 180
    var user: User?
    var hudLabels: [SKLabelNode] = []
    var planetList: [Planet: [Notification]] = [:]
    let backgroundImageName: String
    var shouldFollowPlanet = false
    
    init(size: CGSize, backgroundImageName: String) {
        self.backgroundImageName = backgroundImageName
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.clear
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let frameCenter = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        var orbitDuration: Double = 60
        sun = SKSpriteNode(imageNamed: "sun1")
        sun.position = frameCenter
        sun.xScale = 0.025
        sun.yScale = 0.025
        sun.zPosition = 1
        addChild(sun)
        cameraNode = SKCameraNode()
        cameraNode.position = sun.position
        camera = cameraNode
        addChild(cameraNode)

        // Variables to store the current orbit size and increment amount
        var currentOrbitSize: CGFloat = initialOrbitSize * 1.85
        let orbitSizeIncrement: CGFloat = 1.45

        for (planet, _) in planetList {
            let orbitNode = OrbitNode(orbitSize: currentOrbitSize, center: frameCenter, strokeColor: .gray)
            orbitNode.zRotation = inclinationAngle
            orbitNode.position = frameCenter
            //TODO: Fix the orbit label
            orbitLabel(planetPosition: planet.position ?? 1, orbitNode: orbitNode)
            let planetNode = PlanetNode(planet: planet, imageNamed: planet.image!, view: view)
            let initialPosition = pointOnPath(path: orbitNode.getOrbitPath(), atPercentOfLength: 2.0, angle: orbitNode.orbitRotation)
            planetNode.position = initialPosition
            planetNode.zRotation = inclinationAngle
            planetNode.xScale = 0.011
            planetNode.yScale = 0.011
            orbitNode.addChild(planetNode)
            planetNode.zPosition = 1
            self.addChild(orbitNode)
            let followPath = SKAction.follow(orbitNode.getOrbitPath(), asOffset: false, orientToPath: false, duration: orbitDuration)
            let movePlanetToStartPosition = SKAction.run {
                planetNode.position = initialPosition
            }
            let sequence = SKAction.sequence([movePlanetToStartPosition, followPath])
            planetNode.run(SKAction.repeatForever(sequence))
            let repeatForever = SKAction.repeatForever(followPath)
            planetNode.run(repeatForever)
            orbitDuration = orbitDuration * 2
            // Update the current orbit size for the next planet
            currentOrbitSize *= orbitSizeIncrement
        }
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        setupHUD()
        createStarLayers()
        
    }
    func orbitLabel(planetPosition: Int, orbitNode: OrbitNode) {
        let orbitLabelText = setOrbitInfo(planetPosition: planetPosition)
        let orbitLabel = SKLabelNode(text: orbitLabelText)
        orbitLabel.color = .white
        orbitLabel.fontSize = 30
        
        // Calculate the label position
        let orbitRadius = max(orbitNode.frame.size.width, orbitNode.frame.size.height) / 2
        let labelPositionX = orbitNode.position.x + orbitRadius * cos(orbitNode.zRotation)
        let labelPositionY = orbitNode.position.y + orbitRadius * sin(orbitNode.zRotation)

        // Position the label and add it to the orbit node
        orbitLabel.position = CGPoint(x: labelPositionX, y: labelPositionY)
        orbitNode.addChild(orbitLabel)
    }
    
    func setOrbitInfo(planetPosition: Int) -> String {
        switch planetPosition {
        case 1: return "1 - 5 Days"
        case 2: return "1 - 2 Weeks"
        case 3: return "1 Month"
        default: return "Error"

        }
    }
    
    func handlePlanetTapped(planetInfo: Planet) {
        solarSystemDelegate?.planetSelected(planetInfo: planetInfo)
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
    
    func setupHUD() {
        guard let user = user else { return }
        let padding: CGFloat = 30
        let fullNameLabel = SKLabelNode(text: user.fullName + "'s")
        fullNameLabel.fontName = "StarcruiserExpandedSemi-Italic"
        fullNameLabel.fontSize = 30
        fullNameLabel.fontColor = .white
        fullNameLabel.position = CGPoint(x: 0, y: size.height / 2 - 30 - padding)
        fullNameLabel.horizontalAlignmentMode = .center
        fullNameLabel.verticalAlignmentMode = .center
        cameraNode.addChild(fullNameLabel)
        hudLabels.append(fullNameLabel)
        let orbitLabel = SKLabelNode(text: "Orbit")
        orbitLabel.fontName = "StarcruiserExpandedSemi-Italic"
        orbitLabel.fontSize = 15
        orbitLabel.fontColor = .white
        orbitLabel.position = CGPoint(x: 0, y: size.height / 2 - 60 - (padding - 10))
        orbitLabel.horizontalAlignmentMode = .center
        orbitLabel.verticalAlignmentMode = .center
        cameraNode.addChild(orbitLabel)
        hudLabels.append(orbitLabel)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchLocation = nil
    }
    
    func starfieldEmitterNode(speed: CGFloat, lifetime: CGFloat, scale: CGFloat, birthRate: CGFloat, color: SKColor, cameraNode: SKCameraNode) -> SKEmitterNode {
        let star = SKLabelNode(fontNamed: "Helvetica")
        star.fontSize = 80.0
        star.text = "✦"
        let textureView = SKView()
        let texture = textureView.texture(from: star)
        texture!.filteringMode = .nearest
        let emitterNode = SKEmitterNode()
        emitterNode.targetNode = self
        emitterNode.particleTexture = texture
        emitterNode.particleBirthRate = birthRate
        emitterNode.particleColor = color
        emitterNode.particleLifetime = lifetime
        emitterNode.particleSpeed = speed
        emitterNode.particleScale = scale
        emitterNode.particleColorBlendFactor = 1
        emitterNode.position = CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + frame.height / 2)
        emitterNode.particlePositionRange = CGVector(dx: frame.maxX * 2, dy: frame.midY)
        emitterNode.particleSpeedRange = 16.0
        // Rotates the stars
        emitterNode.particleAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(byAngle: -CGFloat.pi / 4, duration: 1),
            SKAction.rotate(byAngle: CGFloat.pi / 4, duration: 1)]))
        // Causes the stars to twinkle
        let twinkles = 20
        let colorSequence = SKKeyframeSequence(capacity: twinkles * 2)
        let twinkleTime = 1.0 / CGFloat(twinkles)
        for i in 0..<twinkles {
            colorSequence.addKeyframeValue(SKColor.white, time: CGFloat(i) * 2 * twinkleTime / 2)
            colorSequence.addKeyframeValue(SKColor.yellow, time: (CGFloat(i) * 2 + 1) * twinkleTime / 2)
        }
        emitterNode.particleColorSequence = colorSequence
        emitterNode.advanceSimulationTime(Double(lifetime))
        return emitterNode
    }
    
    //for using two fingers to zoom
    @objc func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began {
            initialCameraScale = cameraNode.xScale
        }
        
        if gestureRecognizer.state == .changed {
            let newScale = initialCameraScale / gestureRecognizer.scale
            let clampedScale = max(0.5, min(newScale, 2.0))  // Clamp the scale between 0.5 and 2.0
            cameraNode.setScale(clampedScale)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if shouldFollowPlanet, let selectedPlanetNode = selectedPlanetNode {
            let planetPositionInScene = selectedPlanetNode.convert(selectedPlanetNode.position, to: self)
            cameraNode.position = CGPoint(x: planetPositionInScene.x, y: planetPositionInScene.y - size.height * 1/6)
        }
    }
    func pointOnPath(path: CGPath, atPercentOfLength percent: CGFloat, angle: CGFloat) -> CGPoint {
        let t = min(max(percent, 0), 1)
        let point = pointAtPercentOfPath(path: path, percent: t)
        return rotatePoint(point: point, byAngle: angle)
    }

    func rotatePoint(point: CGPoint, byAngle angle: CGFloat) -> CGPoint {
        let s = sin(angle)
        let c = cos(angle)
        let x = point.x * c - point.y * s
        let y = point.x * s + point.y * c
        return CGPoint(x: x, y: y)
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
    
    func createStarLayers() {
        // A layer of a star field
        let starfieldNode = SKNode()
        starfieldNode.name = "starfieldNode"
        starfieldNode.zPosition = -1
        starfieldNode.addChild(starfieldEmitterNode(speed: -12, lifetime: size.height / 18, scale: 0.20, birthRate: 0.1, color: SKColor.lightGray, cameraNode: cameraNode))
        addChild(starfieldNode)

        // A second layer of stars
        let emitterNode2 = starfieldEmitterNode(speed: -8, lifetime: size.height / 14, scale: 0.12, birthRate: 0.25, color: SKColor.gray, cameraNode: cameraNode)
        emitterNode2.zPosition = -10
        starfieldNode.addChild(emitterNode2)

        // A third layer
        let emitterNode3 = starfieldEmitterNode(speed: -1, lifetime: size.height / 12, scale: 0.05, birthRate: 1, color: SKColor.darkGray, cameraNode: cameraNode)
        starfieldNode.addChild(emitterNode3)
    }
    
    func toggleHUDLabelsVisibility() {
        for label in hudLabels {
            label.isHidden.toggle()
        }
    }
}
