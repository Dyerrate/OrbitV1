//
//  LoginViewController.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit
import SafariServices
import AuthenticationServices

class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    var animationTimer: Timer?

    override func viewDidLoad() {
        //        animationTimer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(self.runRandomAnimation), userInfo: nil, repeats: true)
        
        super.viewDidLoad()
        setupBackgroundImage()
        let (_, orbitLabel) = setupMyOrbitTitle()
        setupSpaceThemeAppleSignInButton(below: orbitLabel)
        setupInfoButton()
    }
//    deinit {
//        // Invalidate timer when view controller is deallocated to prevent memory leaks
//        animationTimer?.invalidate()
//    }
    
    
    func setupInfoButton() {
        let infoButton = UIButton(type: .system)
        let infoIcon = UIImage(systemName: "questionmark.circle")
        infoButton.setImage(infoIcon, for: .normal)
        infoButton.tintColor = UIColor.gray.withAlphaComponent(0.5)
        infoButton.addTarget(self, action: #selector(handleInfoButton), for: .touchUpInside)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoButton)

        NSLayoutConstraint.activate([
            infoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            infoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    @objc func handleInfoButton() {
        // Display info panel about the app
    }

    
    @objc func handleAppleSignInButton() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    func setupBackgroundImage() {
        // Create UIImageView
        let backgroundImageView = UIImageView()
        
        // Set the image property to 'backgroundImage' from assets
        backgroundImageView.image = UIImage(named: "backgroundImage")
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func setupSpaceThemeAppleSignInButton(below titleLabel: UILabel) {
        let appleSignInButton = ASAuthorizationAppleIDButton()
        appleSignInButton.addTarget(self, action: #selector(handleAppleSignInButton), for: .touchUpInside)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(appleSignInButton)
        NSLayoutConstraint.activate([
            appleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: view.frame.height / 3.7),
            appleSignInButton.widthAnchor.constraint(equalToConstant: 200),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    func setupMyOrbitTitle() -> (myLabel: UILabel, orbitLabel: UILabel) {
        let myLabel = UILabel()
        myLabel.text = "My"
        myLabel.font = UIFont(name: "StarcruiserExpandedSemi-Italic", size: 75)
        myLabel.textColor = .white
        myLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myLabel)

        let orbitLabel = UILabel()
        orbitLabel.text = "Orbit"
        orbitLabel.font = UIFont(name: "StarcruiserExpandedSemi-Italic", size: 75)
        orbitLabel.textColor = .white
        orbitLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(orbitLabel)
        //NOTE: Remove comments to print fonts
//        for family in UIFont.familyNames {
//            for name in UIFont.fontNames(forFamilyName: family) {
//                print(name)
//            }
//        }
        NSLayoutConstraint.activate([
            orbitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orbitLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -view.frame.height / 3.5),
            myLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            myLabel.bottomAnchor.constraint(equalTo: orbitLabel.topAnchor, constant: 17) // Adjust this constant value to change the spacing
        ])

        return (myLabel, orbitLabel)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            var fullName = ""
            if let givenName = appleIDCredential.fullName?.givenName,
               let familyName = appleIDCredential.fullName?.familyName {
                fullName = "\(givenName) \(familyName)"
            }
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email

            UserManager.shared.getUser(by: userIdentifier, fullName: fullName, email: email) { result in
                switch result {
                case .success(let user):
                    if let user = user {
                        DispatchQueue.main.async {
                            self.showLoadingScreen(for: user)
                        }
                    } else {
                        print("Failed to fetch or create user")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }


    private func showLoadingScreen(for user: User) {
        let loadingViewController = LoadingViewController()
        loadingViewController.currentUser = user
        print("we pass in the user: ", user)
        print("show loading screen")
        navigationController?.pushViewController(loadingViewController, animated: true)
    }
    
    private func checkNotificationAccess() {
        NotificationManager().checkAccess { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    // Access granted, navigate to SolarSystemViewController
                } else {
                    self.showAlertToEditSettings()
                }
            }
        }
    }
    private func showAlertToEditSettings() {
        let alertController = UIAlertController(title: "Notification Access Required", message: "Please enable notifications in your device's settings.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    //~~~Animations~~~
    
//    @objc func runRandomAnimation() {
//        //["meteor", "spaceship", "satellite"]
//        let animations = ["meteor"]
//        let randomAnimation = animations.randomElement()
//
//        switch randomAnimation {
//        case "meteor":
//            runMeteorAnimation()
////        case "spaceship":
////            runSpaceshipAnimation()
////        case "satellite":
////            runSatelliteAnimation()
//        default:
//            break
//        }
//    }
//    func runMeteorAnimation() {
//        // Create an UIImageView for your meteor
//        let meteor = UIImageView(image: UIImage(named: "meteor1"))
//        let randomStartY = randomYValue()
//        let randomEndY = randomYValue()
//
//        // Start the meteor outside the screen on the right
//        meteor.frame = CGRect(x: self.view.frame.maxX + 100, y: randomStartY, width: 100, height: 100)
//
//        // Add it to your view
//        self.view.addSubview(meteor)
//
//        // Animate the meteor flying from right to left
//        UIView.animate(withDuration: 2.0, animations: {
//            // End the meteor outside the screen on the left
//            meteor.frame = CGRect(x: -100, y: randomEndY, width: 100, height: 100)
//        }, completion: { _ in
//            // Remove the meteor from the view after the animation completes
//            meteor.removeFromSuperview()
//        })
//    }
//    func randomYValue() -> CGFloat {
//          return CGFloat(arc4random_uniform(UInt32(self.view.frame.maxY)))
//      }
    
}

