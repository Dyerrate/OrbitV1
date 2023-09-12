//
//  SolarSystemViewController.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit
import SpriteKit

protocol SolarSystemSceneDelegate: AnyObject {
    func planetSelected(planetInfo: Planet)
    func planetTapped()
}

class SolarSystemViewController: UIViewController, SolarSystemSceneDelegate, PlanetActionViewDelegate {
    private var initialNotifications: [Notification]?
    let userManager = UserManager()
    let notificationManager = NotificationManager()
    private var planetManager: PlanetManager?
    private var skView: SKView!
    private var notificationListView: NotificationListView?
    private var planetActionView: PlanetActionView?
    private var selectedPlanetName: String?
    var navBar: UINavigationBar?
    //Users data attributes
    var user: User?
    var planetList: [Planet: [Notification]] = [:]
    var notificationLists: [Notification] = []
    var currentPlanet: Planet?
    private var selectedPlanetOrbit: String?
    var notificationCount: String?
    
    func planetSelected(planetInfo: Planet) {
        selectedPlanetName = planetInfo.name
        currentPlanet = planetInfo
        updateNotificationsList(for: planetInfo)
        planetTapped()
    }
    func updateNavBar(isThere: Int) {
        // Remove the old navigation bar if it exists
        self.navBar?.removeFromSuperview()
        self.navBar = nil
        if(isThere > 0) {
            // Create a new navigation bar
            let statusBarHeight: CGFloat
            if #available(iOS 13.0, *) {
                statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            } else {
                statusBarHeight = UIApplication.shared.statusBarFrame.height
            }
            self.navBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: view.bounds.width, height: 44))
            self.navBar?.backgroundColor = .clear
            self.navBar?.isTranslucent = true
            self.navBar?.setBackgroundImage(UIImage(), for: .default)
            self.navBar?.shadowImage = UIImage()
            self.navBar?.translatesAutoresizingMaskIntoConstraints = false
        }
        // Add the new navigation bar to the view
        if let navBar = self.navBar {
            navBar.isHidden = false
            planetActionView?.activeNotificationsView.addSubview(navBar)
            
            // Set constraints for navBar to make it appear above planetActionView.tableView
            if let planetActionView = self.planetActionView {
                NSLayoutConstraint.activate([
                    navBar.bottomAnchor.constraint(equalTo: planetActionView.tableView.topAnchor),
                    navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
                ])
            }
        } else {
            self.navBar?.isHidden = true
        }
        // Create a UINavigationItem with the Edit button
        let navigationItem = UINavigationItem(title: "")
        navigationItem.rightBarButtonItem = self.editButtonItem
        // Set the navigation bar's items
        self.navBar?.setItems([navigationItem], animated: false)
        // Set the navigation bar's items
        self.navBar?.setItems([navigationItem], animated: false)
    }
    //INFO: For adding a contact
    func planetActionViewAlertAddContact() {
        let alert = UIAlertController(title: "Error", message: "A notification for this contact already exists.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateNotificationListDB(updateNotifications: [Notification], planetInfo: Planet, option: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var newNotifications = [Notification]()
        for updateNotification in updateNotifications {
            if !notificationLists.contains(where: {$0.title == updateNotification.title}) {
                newNotifications.append(updateNotification)
            }
        }
        print("before the userManager")
        switch option {
        case "Add":
            if let existingNotifications = self.planetList[planetInfo] {
                self.planetList[planetInfo] = existingNotifications + newNotifications
            } else {
                self.planetList[planetInfo] = newNotifications
            }
            userManager.addPlanetNotificationList(user: user!, planet: planetInfo, notifications: newNotifications) { result in
                print("during the userManager for add")
                switch result {
                case .success(let returnedNotifications):
                    for notificationRecord in returnedNotifications {
                        if let index = self.planetList[planetInfo]?.firstIndex(where: { $0.title == notificationRecord["title"] }) {
                            self.planetList[planetInfo]?[index].recordID = notificationRecord.recordID
                        }
                    }
                    self.updateNotificationListNoPriorities(for: planetInfo)
                    completion(.success(()))
                    print("Successfully updated notification list and are sending notifications.")
                case .failure(let error):
                    completion(.failure((error)))
                    print("Failed to update notification list: \(error)")
                }
            }
        case "Delete":
            if var existingNotifications = self.planetList[planetInfo] {
                existingNotifications.removeAll(where: { (notification) -> Bool in
                    updateNotifications.contains(where: { $0.title == notification.title })
                })
                self.planetList[planetInfo] = existingNotifications
                self.updateNotificationListNoPriorities(for: planetInfo)
                // Then, update the database in the background
                userManager.removePlanetNotificationList(user: user!, planet: planetInfo, notifications: updateNotifications) { result in
                    print("during the userManager deletion: sent:", newNotifications)
                    switch result {
                    case .success():
                        print("Successfully removed/updated notification list.")
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure((error)))
                        print("Failed to update notification list: \(error)")
                    }
                }
            } else {
                print("No notifications to delete.")
            }
        default:
            print("it didn't work")
        }
    }
    
    func updateNotificationsList(for planet: Planet) {
        notificationLists = planetList[planet] ?? []
        notificationLists.sort { $0.priority < $1.priority }
        notificationCount = String(notificationLists.count)
        planetActionView?.updateNotificationPriorities()
        print("We have updated the notification list yay")
    }
    
    func updateNotificationListNoPriorities(for planet: Planet) {
        notificationLists = planetList[planet] ?? []
        notificationLists.sort { $0.priority < $1.priority }
        notificationCount = String(notificationLists.count)
        print("We updated with no planetActionView call")
    }

    func planetTapped() {
        showPlanetActionView()
        planetActionView?.updatePlanetName(planetName: selectedPlanetName)
        let updatedNotificationList = planetList[currentPlanet!] ?? []
        planetActionView?.updateTappedPlanetInfo(planet: currentPlanet!, notificationList: updatedNotificationList)
        print("planet tapped")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setupSKView()
        presentSolarSystemScene()
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    private func setupSKView() {
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        planetActionView?.tableView.setEditing(editing, animated: animated)
    }
    //INFO: Displaying the planet panel
    //TODO: REFACTOR THIS ALOT - idk yt it
    private func showPlanetActionView() {
        if planetActionView == nil {
            planetActionView?.changedNotifications = []
            planetActionView?.priorityChange = false
            planetActionView = PlanetActionView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height * 2/3), notifications: notificationLists)
            planetActionView?.delegate = self
            view.addSubview(planetActionView!)
        } else {
            let dispatchForPriority = DispatchGroup()
            let dispatchForDelete = DispatchGroup()
            if planetActionView?.changedNotifications != nil {
                print("We are trying to change DB")
                var addNotification: [Notification] = []
                var deleteNotification: [Notification] = []
                for update in planetActionView!.changedNotifications {
                    let action = update.action
                    let notification = update.notification
                    switch action {
                    case "add":
                        addNotification.append(update.notification)
                        print("We add a notification to send: add")
                        // Logic to add the notification
                    case "delete":
                        deleteNotification.append(update.notification)
                        print("We add a notification to send: delete")
                        // Logic to delete the notification
                    default:
                        continue
                    }
                }
                if !deleteNotification.isEmpty {
                    var newAdd = addNotification
                    addNotification = []
                    dispatchForDelete.enter()
                    updateNotificationListDB(updateNotifications: deleteNotification, planetInfo: currentPlanet!, option: "Delete") {result in
                        switch result {
                        case .success():
                            print("pray to fucking god this works 2")
                            dispatchForDelete.leave()
                        case .failure(let error):
                            print("on my moms tits2: \(error)")
                        }
                        //When deletion is done, we do the add, if needed
                        dispatchForDelete.notify(queue: .main){
                            if !newAdd.isEmpty {
                                print("before we enter the dispatch: ADD in dispatch")
                                dispatchForPriority.enter()
                                self.updateNotificationListDB(updateNotifications: newAdd, planetInfo: self.currentPlanet!, option: "Add") {result in
                                    switch result {
                                    case .success():
                                        print("pray to fucking god this works 1.1")
                                        dispatchForPriority.leave()
                                        
                                    case .failure(let error):
                                        print("on my moms tits1.1: \(error)")
                                    }
                                    dispatchForPriority.notify(queue: .main) {
                                        if(self.planetActionView?.priorityChange == true) {
                                            self.checkForPriorityUpdate(planetOrbit: (self.currentPlanet?.position)!)
                                            print("SENDING: To update priority notificationManager - 1")
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
                if !addNotification.isEmpty {
                    print("before we enter the dispatch: ADD")
                    dispatchForPriority.enter()
                    updateNotificationListDB(updateNotifications: addNotification, planetInfo: currentPlanet!, option: "Add") {result in
                        switch result {
                        case .success():
                            print("pray to fucking god this works 1.2")
                            dispatchForPriority.leave()
                        case .failure(let error):
                            print("on my moms tits1.2: \(error)")
                        }
                        dispatchForPriority.notify(queue: .main) {
                            if(self.planetActionView?.priorityChange == true) {
                                self.checkForPriorityUpdate(planetOrbit: (self.currentPlanet?.position)!)
                                print("SENDING: To update priority notificationManager - 2")
                            }
                        }
                    }
                }
                if(self.planetActionView?.priorityChange == true && addNotification.isEmpty && deleteNotification.isEmpty) {
                    checkForPriorityUpdate(planetOrbit: (self.currentPlanet?.position)!)
                    print("SENDING: To update priority notificationManager - 3")
                }
            }
            
            self.clearPlanetActionView()
        }
        UIView.animate(withDuration: 0.3) {
            self.planetActionView?.frame.origin.y = self.view.bounds.height * 1/3
        }
    }
    
    private func checkForPriorityUpdate(planetOrbit: Int) {
        let currentNotifications: [Notification] = planetActionView!.notifications
        if !currentNotifications.isEmpty {
            userManager.updateNotificationPriority(notifications: currentNotifications){ result in
                switch result {
                case .success():
                    print("We have updated from the checkForPriorityUpdate")
                    self.notificationManager.updateFromSolarSystem(planetList: self.planetList, planetOrbit: planetOrbit)
                    print("Sending notificationManager Main: \(planetOrbit)")
                    
                case . failure(let error):
                    print("We failed to update from checkForPriorityUpdate: ", error)
                }
            }
        }
    }
    
    //Clearing all displays after the planet is tapped while ~ZOOMED~
    private func clearPlanetActionView() {
        planetActionView?.removeFromSuperview()
        planetActionView = nil
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
    }

}
extension Notification: Equatable {
    static func == (lhs: Notification, rhs: Notification) -> Bool {
        return lhs.title == rhs.title && lhs.type == rhs.type
    }
}
