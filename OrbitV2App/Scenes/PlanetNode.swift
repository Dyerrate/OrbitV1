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
        handleTap()
    }
    
    func handleTap() {
        guard let view = view else { return }
        let planetView = PlanetView(planet: planet)
        planetView.frame = view.bounds
        view.addSubview(planetView)
    }
}
