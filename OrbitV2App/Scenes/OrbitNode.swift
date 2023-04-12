//
//  OrbitNode.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/11/23.
//

import SpriteKit

class OrbitNode: SKNode {
    init(width: CGFloat, height: CGFloat, center: CGPoint, rotationAngle: CGFloat, strokeColor: UIColor) {
        super.init()
        
        let orbit = createOvalPath(width: width, height: height, center: center, rotationAngle: rotationAngle, strokeColor: strokeColor)
        addChild(orbit)
        
        self.path = createOvalPath(width: width, height: height, center: center, rotationAngle: rotationAngle, strokeColor: .clear).path
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var path: CGPath?
    
    private func createOvalPath(width: CGFloat, height: CGFloat, center: CGPoint, rotationAngle: CGFloat, strokeColor: UIColor) -> SKShapeNode {
        let path = UIBezierPath(ovalIn: CGRect(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height))
        let newPath = CGMutablePath()
        let transform = CGAffineTransform(rotationAngle: rotationAngle)
        newPath.addPath(path.cgPath, transform: transform)
        
        let shapeNode = SKShapeNode(path: newPath)
        shapeNode.strokeColor = strokeColor
        shapeNode.lineWidth = 1
        return shapeNode
    }
}
