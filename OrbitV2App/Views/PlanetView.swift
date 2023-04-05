//
//  PlanetView.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit

class PlanetView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        let planetLayer = CAShapeLayer()
        planetLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        planetLayer.fillColor = UIColor.red.cgColor
        layer.addSublayer(planetLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
