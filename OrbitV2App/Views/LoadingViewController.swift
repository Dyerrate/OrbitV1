//
//  LoadingViewController.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/5/23.
//

import Foundation
import UIKit
import UserNotifications

class LoadingViewController: UIViewController {
    var currentUser: User?
    var loadingProgressView: UIProgressView!
    let activityIndicator = UIActivityIndicatorView(style: .large)

    //When the view initially loads
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingProgressView = UIProgressView(progressViewStyle: .default)
        loadingProgressView.translatesAutoresizingMaskIntoConstraints = false
        loadingProgressView.alpha = 0
        view.addSubview(loadingProgressView)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.alpha = 0
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingProgressView.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            loadingProgressView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        activityIndicator.startAnimating()
        navigationController?.navigationBar.tintColor = .white
    }
    
    //When the app is closed and re-opened this will run
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Fade in the activityIndicator and loadingProgressView with a 0.5-second delay
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut) {
            self.loadingProgressView.alpha = 1
            self.activityIndicator.alpha = 1
        }
        checkNotificationSettings()
    }
    
    
    
    func updateProgress() {
        loadingProgressView.setProgress(1.0, animated: true)
    }
    
    //When the view appears run this

//function to check the user notifications
    func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    // If user's fullName is empty, show the UI for user to enter fullName
                    if self.currentUser?.fullName.isEmpty ?? true {
                        print("ayy yo we here")
                        self.showUsernameEntryPrompt()
                    } else {
                        print("ayy yo naw we here cuh")
                        // If user's fullName is not empty, show the Solar System page
                        self.showSolarSystemPage()
                    }
                case .denied:
                    // Notifications are disabled, show the prompt to enable notifications
                    self.showNotificationPrompt()
                case .notDetermined:
                    // Request authorization
                    self.requestNotificationAuthorization() { granted in
                        if granted {
                            // If user's fullName is empty, show the UI for user to enter fullName
                            if self.currentUser?.fullName.isEmpty ?? true {
                                self.showUsernameEntryPrompt()
                            } else {
                                // If user's fullName is not empty, show the Solar System page
                                self.showSolarSystemPage()
                            }
                        } else {
                            self.showNotificationPrompt()
                        }
                    }
                default:
                    // Do nothing for other cases
                    break
                }
            }
        }
    }
    
    // Present the solar system view controller here
    func showSolarSystemPage() {
        let solarSystemVC = SolarSystemViewController()
        // Start the progress bar loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.updateProgress()
            // Call setSolarSystem() while the loading bar is running
            UserManager.shared.setSolarSystem(for: self.currentUser!) { planetList in
                DispatchQueue.main.async {
                    if !planetList.isEmpty {
                        // Passing the user
                        solarSystemVC.user = self.currentUser
                        // Passing the planetList
                        solarSystemVC.planetList = planetList
                        self.setBackgroundImage(for: solarSystemVC, imageName: "backgroundImage")
                        // Call the original showSolarSystemPage logic after the progress bar finishes loading
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            solarSystemVC.modalPresentationStyle = .fullScreen
                            solarSystemVC.modalTransitionStyle = .crossDissolve
                            self.present(solarSystemVC, animated: true, completion: nil)
                        }
                    } else {
                        print("Error fetching planets and orbits for the current user.")
                        // Handle the error
                    }
                }
            }
        }
    }
    func setBackgroundImage(for viewController: UIViewController, imageName: String) {
        let backgroundImageView = UIImageView(frame: viewController.view.bounds)
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        viewController.view.insertSubview(backgroundImageView, at: 0)
    }

    func showUsernameEntryPrompt() {
        let alertController = UIAlertController(title: "Enter Username", message: "Please enter your username", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Username"
        }

        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let username = alertController.textFields?[0].text, !username.isEmpty, username.count <= 24 else {
                // If the username is empty or more than 24 characters, show the prompt again
                self.showUsernameEntryPrompt()
                return
            }

            guard let currentUser = self.currentUser else {
                // Handle the case where currentUser is nil
                print("currentUser is nil")
                return
            }
            
            // Update the user's fullName with the entered username
            UserManager.shared.updateUserName(uuid: currentUser.uuid, fullName: username, currentUser: currentUser) { (result) in
                switch result {
                case .success(let user):
                    print("User's fullName updated successfully.")
                    self.currentUser = user  // Update the currentUser with the updated user
                    self.showSolarSystemPage()
                case .failure(let error):
                    print("Failed to update user's fullName: \(error)")
                }
            }
        }

        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func textFieldTextChanged(_ sender: UITextField) {
        var responder: UIResponder? = sender
        while !(responder is UIAlertController) { responder = responder?.next }
        if let alertController = responder as? UIAlertController {
            if let text = sender.text, !text.isEmpty, text.count <= 24 {
                alertController.actions[0].isEnabled = true
            } else {
                alertController.actions[0].isEnabled = false
            }
        }
    }
    func showNotificationPrompt() {
        let alertController = UIAlertController(title: "Enable Notifications", message: "Follow these steps to enable notifications:\n\n1. Open the Settings app\n2. Scroll down and tap on 'AppName'\n3. Tap on 'Notifications'\n4. Enable 'Allow Notifications'\n\nFor more information, check the Apple documentation on enabling notifications: https://support.apple.com/en-us/HT205223", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("Error requesting authorization: \(error.localizedDescription)")
                    } else {
                        print("Notification authorization granted: \(granted)")
                    }
                }
            }
        }
    }
}
