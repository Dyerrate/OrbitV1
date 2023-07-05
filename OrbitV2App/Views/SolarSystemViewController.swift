//
//  SolarSystemViewController.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit
import SpriteKit

protocol SolarSystemSceneDelegate: AnyObject {
    func planetSelected(planetName: String)
    func planetTapped()
}

class SolarSystemViewController: UIViewController, SolarSystemSceneDelegate, PlanetActionViewDelegate {
    private var planetManager: PlanetManager?
    private var skView: SKView!
    private var notificationListView: NotificationListView?
    private var planetActionView: PlanetActionView?
    private var selectedPlanetName: String?
    //Users data attributes
    var user: User?
    var planetList: [Planet: [Notification]] = [:]
    var notificationLists: [Notification] = []
    private var selectedPlanetOrbit: String?
    
    func planetSelected(planetName: String) {
        if let planet = planetList.keys.first(where: { $0.name == planetName }) {
            selectedPlanetName = planet.name
            if let notifications = planetList[planet] {
                notificationLists = notifications
            } else {
                notificationLists = []
                print("No notifications found for the selected planet.")
            }
            planetTapped()
        } else {
            print("Planet not found")
        }
    }

    func planetTapped() {
        print("planet tapped")
        showPlanetActionView()
        planetActionView?.updatePlanetName(planetName: selectedPlanetName)
        
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
    }
    private func presentSolarSystemScene() {
        let scene = SolarSystemScene(size: skView.bounds.size, backgroundImageName: "backgoundImage")
        scene.solarSystemDelegate = self
        scene.scaleMode = .aspectFill
        // Pass the user and planetList to the scene
        scene.user = user
        scene.planetList = planetList
        scene.size = view.bounds.size
        skView.bounds = view.bounds
        skView.backgroundColor = UIColor.clear
        skView.presentScene(scene)
//        planetManager = PlanetManager(loggedInUser: user!, planetList: planetList)
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
            notificationListView = NotificationListView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height * 0.35), loggedIn: user != nil)
            view.addSubview(notificationListView!)
        }
        UIView.animate(withDuration: 0.3) {
            self.notificationListView?.frame.origin.y = self.view.bounds.height / 1.2
        }
    }

    
}

