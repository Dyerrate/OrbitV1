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
    //When the view initially loads
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orbitBackground

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
        navigationController?.navigationBar.tintColor = .white
    }
    
    //When the app is closed and re-opened this will run
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //When the view appears run this
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkNotificationSettings()
    }
//function to check the user notifications
    func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    // Notifications are enabled, proceed to the solar system page
                    self.showSolarSystemPage()
                case .denied:
                    // Notifications are disabled, show the prompt to enable notifications
                    self.showNotificationPrompt()
                case .notDetermined:
                    // Request authorization
                    self.requestNotificationAuthorization() { granted in
                        if granted {
                            self.showSolarSystemPage()
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
        
        //set modal presentation style and transition style
        solarSystemVC.modalPresentationStyle = .fullScreen
        solarSystemVC.modalTransitionStyle = .crossDissolve
        
        //Pesent the View controller and with a fade-in animation
        self.present(solarSystemVC, animated: true, completion: nil)
        
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
