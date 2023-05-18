//
//  SolarSystemViewController.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit
import SpriteKit

protocol SolarSystemSceneDelegate: AnyObject {
    func planetSelected(planetName: String, orbitName: String)
    func planetTapped()
}

class SolarSystemViewController: UIViewController, SolarSystemSceneDelegate, PlanetActionViewDelegate {
    private var skView: SKView!
    private var notificationListView: NotificationListView?
    private var planetActionView: PlanetActionView?
    private var selectedPlanetName: String?
    private var selectedPlanetOrbit: String?
    
    func planetSelected(planetName: String, orbitName: String) {
        selectedPlanetName = planetName
        selectedPlanetOrbit = orbitName
        planetTapped()
    }

    func planetTapped() {
        print("planet tapped")
        showPlanetActionView()
        planetActionView?.updatePlanetName(planetName: selectedPlanetName)
        planetActionView?.updateOrbitName(orbitName: selectedPlanetOrbit)
    }


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
    
    private func showPlanetActionView() {
        if planetActionView == nil {
            planetActionView = PlanetActionView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height * 2/3))
            planetActionView?.delegate = self
            view.addSubview(planetActionView!)
        } else {
            clearPlanetActionView()
        }

        UIView.animate(withDuration: 0.3) {
            self.planetActionView?.frame.origin.y = self.view.bounds.height * 1/3
        }
    }
    
    //Clearing all displays after the planet is tapped while ~ZOOMED~
    private func clearPlanetActionView() {
        planetActionView?.removeFromSuperview()
        planetActionView = nil
        hideNotificationsListView()
//        planetActionView?.removeSubViews()
    }
    private func presentSolarSystemScene() {
        let scene = SolarSystemScene(size: skView.bounds.size)
        scene.solarSystemDelegate = self // Add this line
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
    func viewButtonTapped() {
          showNotifications()
      }
    
    func editButtonTapped() {
    
    }
    func returnButtonTapped() {
//        planetActionView?.resetToInitialState()
        hideNotificationsListView()
    }
    func hideNotificationsListView() {
        notificationListView?.removeFromSuperview()
        notificationListView = nil
        print("showNotifications DELETE")
    }
    func showNotifications() {
        if notificationListView == nil {
            print("showNotifications APPEAR")
            notificationListView = NotificationListView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height * 0.35), loggedIn: true)
            view.addSubview(notificationListView!)
        }
        UIView.animate(withDuration: 0.3) {
            self.notificationListView?.frame.origin.y = self.view.bounds.height / 1.2
        }
    }

    
}

