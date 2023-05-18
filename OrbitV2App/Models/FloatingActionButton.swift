//
//  FloatingActionButton.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/27/23.
//

import Foundation
import UIKit

class FloatingActionButton: GradientButton {

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        layer.cornerRadius = 40
        addGradientBackground(colors: [UIColor.spacePurple1.cgColor, UIColor.spacePurple2.cgColor])
        setTitleColor(.white, for: .normal)
        addShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class GradientButton: UIButton {
    var gradientLayer: CAGradientLayer?

    func addGradientBackground(colors: [CGColor]) {
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = bounds
        gradientLayer?.colors = colors
        gradientLayer?.cornerRadius = layer.cornerRadius
        if let gradient = gradientLayer {
            layer.insertSublayer(gradient, at: 0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }

    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.3
    }
}
