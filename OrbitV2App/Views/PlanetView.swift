//
//  PlanetView.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit

class PlanetView: UIButton {
    private(set) var planet: Planet

    init(planet: Planet) {
        self.planet = planet
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        setImage(planet.image, for: .normal)
        imageView?.contentMode = .scaleAspectFit
        addTarget(self, action: #selector(planetTapped), for: .touchUpInside)
    }

    @objc private func planetTapped() {
        // Perform any action when the planet is tapped
    }
    func show(in view: UIView) {
        view.addSubview(self)
    }
}

//class PlanetView: UIView {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .clear
//
//        let planetLayer = CAShapeLayer()
//        planetLayer.path = UIBezierPath(ovalIn: bounds).cgPath
//        planetLayer.fillColor = UIColor.red.cgColor
//        layer.addSublayer(planetLayer)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
