//
//  PlanetView.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit

class PlanetView: UIButton {
    private(set) var planet: Planet
    var imageName: String?

    init(planet: Planet) {
        self.planet = planet
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        // Create a UIImage from the string and set it as the button's image
        if let imageName = planet.image, let image = UIImage(named: imageName) {
            setImage(image, for: .normal)
        }

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
