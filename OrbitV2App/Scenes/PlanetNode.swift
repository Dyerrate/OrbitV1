//
//  PlanetNode.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/9/23.
//

import SpriteKit

class PlanetNode: SKSpriteNode {
    private var planet: Planet
    private var skView: SKView?
    
    init(planet: Planet, view: SKView? = nil) {
        self.planet = planet
        self.skView = view
        let texture = SKTexture(image: planet.image)
        super.init(texture: texture, color: .clear, size: texture.size())
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Planet tapped: \(planet.name)")

        if let view = skView {
            let planetView = PlanetView(planet: planet)
            planetView.frame = view.bounds
            planetView.show(in: view)
        }
    }
}
