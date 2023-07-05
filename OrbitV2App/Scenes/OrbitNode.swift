//
//  OrbitNode.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/11/23.
//

import SpriteKit

class OrbitNode: SKNode {
    private let width: CGFloat
    private let height: CGFloat
    var orbitRotation: CGFloat {
        return zRotation
    }
    init(orbitSize: CGFloat, center: CGPoint, strokeColor: UIColor) {
        self.width = orbitSize
        self.height = orbitSize * 1.5 // Multiply the height by a factor (1.5) to make the path oval
        super.init()

        let orbitPath = createOvalPath(width: width, height: height, center: center, strokeColor: strokeColor)
        addChild(orbitPath)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createOvalPath(width: CGFloat, height: CGFloat, center: CGPoint, strokeColor: UIColor) -> SKShapeNode {
        let path = UIBezierPath(ovalIn: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))
        let shapeNode = SKShapeNode(path: path.cgPath)
        
        shapeNode.strokeColor = strokeColor
        shapeNode.lineWidth = 1
        return shapeNode
    }
    func getOrbitPath() -> CGPath {
        return (children.first as! SKShapeNode).path!
    }
}
