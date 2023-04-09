//
//  SolarSystemViewController.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit
import SpriteKit

class SolarSystemViewController: UIViewController {
    private var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupSKView()
        presentSolarSystemScene()
    }

    private func setupSKView() {
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
    }

    private func presentSolarSystemScene() {
        let scene = SolarSystemScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
}
