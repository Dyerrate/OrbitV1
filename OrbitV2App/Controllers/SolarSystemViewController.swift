//
//  SolarSystemViewController.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit

class SolarSystemViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let planetView = PlanetView()
        view.addSubview(planetView)
        
        planetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            planetView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            planetView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            planetView.widthAnchor.constraint(equalToConstant: 50),
            planetView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
