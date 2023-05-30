//
//  OrbitNode.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/11/23.
//

import SpriteKit

class OrbitNode: SKNode {
    private let orbit: Orbit
    private let width: CGFloat
    private let height: CGFloat
    
    init(orbit: Orbit, center: CGPoint, rotationAngle: CGFloat, strokeColor: UIColor) {
        self.orbit = orbit
        self.width = orbit.width
        self.height = orbit.height
        super.init()
        print("this is the width: ", width)
        print("this is the height: ", height)

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
        
        // Apply rotation and translation to the path
        let transform = CGAffineTransform(rotationAngle: rotationAngle)
            .translatedBy(x: center.x, y: center.y)
            .translatedBy(x: -center.x, y: -center.y)
        newPath.addPath(path.cgPath, transform: transform)
        
        let shapeNode = SKShapeNode(path: newPath)
        shapeNode.strokeColor = strokeColor
        shapeNode.lineWidth = 1
        return shapeNode
    }
}
