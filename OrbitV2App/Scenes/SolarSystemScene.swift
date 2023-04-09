//
//  SolarSystemScene.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/8/23.
//

import SpriteKit

class SolarSystemScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = .black

        let planet1 = Planet(name: "planet1", image: UIImage(named: "planet1")!)
        let planet2 = Planet(name: "planet2", image: UIImage(named: "planet2")!)
        let planet3 = Planet(name: "planet3", image: UIImage(named: "planet3")!)
        let planetNode1 = PlanetNode(planet: planet1, view: view)
        let planetNode2 = PlanetNode(planet: planet2, view: view)
        let planetNode3 = PlanetNode(planet: planet3, view: view)

        // Set the position of the planet nodes
        planetNode1.position = CGPoint(x: size.width / 4, y: size.height / 2)
        planetNode1.xScale = 0.1
        planetNode1.yScale = 0.1
        planetNode2.position = CGPoint(x: size.width / 2, y: size.height / 2)
        planetNode2.xScale = 0.1
        planetNode2.yScale = 0.1
        planetNode3.position = CGPoint(x: 3 * size.width / 4, y: size.height / 2)
        planetNode3.xScale = 0.1
        planetNode3.yScale = 0.1

        // Add the planet nodes to the scene
        addChild(planetNode1)
        addChild(planetNode2)
        addChild(planetNode3)

        let rotation = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 10)
        let repeatRotation = SKAction.repeatForever(rotation)
        planetNode1.run(repeatRotation)
        planetNode2.run(repeatRotation)
        planetNode3.run(repeatRotation)
    }
}
