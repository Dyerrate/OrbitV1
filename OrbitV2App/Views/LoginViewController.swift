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
    var overlay: UIView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        let orbitLabel = setupMyOrbitTitle()
        setupSpaceThemeAppleSignInButton(below: orbitLabel)
        setupInfoButton()
        setBackgroundImage(for: self, imageName: "backgroundImage")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateImagesSlideUp()
    }
    
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
    
    @objc func handleAppleSignInButton() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    func setupBackgroundImage() {
        let backgroundImageView = createImageView(imageName: "backgroundImage", contentMode: .scaleAspectFill)
        let homePlanetImageView = createImageView(imageName: "homePlanet", contentMode: .scaleAspectFill, scale: 0.428, tag: 100)
        let loginBottomImageView = createImageView(imageName: "bottomLogin", contentMode: .scaleAspectFill, scale: 0.3, tag: 101)

        view.addSubview(backgroundImageView)
        view.addSubview(loginBottomImageView)
        view.insertSubview(homePlanetImageView, belowSubview: loginBottomImageView)
        NSLayoutConstraint.activate([
            // BackgroundImageView constraints
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // LoginBottomImageView constraints
            loginBottomImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginBottomImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginBottomImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loginBottomImageView.heightAnchor.constraint(equalToConstant: loginBottomImageView.image!.size.height),

            // HomePlanetImageView constraints
            homePlanetImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -20),
            homePlanetImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 53),
            homePlanetImageView.widthAnchor.constraint(equalToConstant: homePlanetImageView.image!.size.width),
            homePlanetImageView.heightAnchor.constraint(equalToConstant: homePlanetImageView.image!.size.height),


        ])
    }
    
    func createImageView(imageName: String, contentMode: UIView.ContentMode, scale: CGFloat = 1.0, tag: Int? = nil) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = contentMode
        imageView.translatesAutoresizingMaskIntoConstraints = false

        if scale != 1.0, let originalImageSize = imageView.image?.size {
            imageView.widthAnchor.constraint(equalToConstant: originalImageSize.width * scale).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: originalImageSize.height * scale).isActive = true
        }
        
        if let tag = tag {
            imageView.tag = tag
        }

        return imageView
    }
    
    func setupSpaceThemeAppleSignInButton(below titleLabel: UILabel) {
        let appleSignInButton = ASAuthorizationAppleIDButton()
        appleSignInButton.tag = 102
        appleSignInButton.alpha = 0
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
    func setupMyOrbitTitle() -> (UILabel) {

        let orbitLabel = UILabel()
        orbitLabel.tag = 103
        orbitLabel.alpha = 0
        orbitLabel.text = "Orbit"
        orbitLabel.font = UIFont(name: "StarcruiserExpandedSemi-Italic", size: 95)
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
        ])

        return (orbitLabel)
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

        // Set the background image of the loading view controller to match the login view controller
        setBackgroundImage(for: loadingViewController, imageName: "backgroundImage")

        // Perform the closing animation
        closeAnimation {
            print("we pass in the user: ", user)
            print("show loading screen")
            self.navigationController?.pushViewController(loadingViewController, animated: false)
        }
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
    
    func setBackgroundImage(for viewController: UIViewController, imageName: String) {
        let backgroundImage = UIImage(named: imageName)
        let backgroundImageView = UIImageView(frame: viewController.view.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = backgroundImage
        viewController.view.insertSubview(backgroundImageView, at: 0)
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func animateImagesSlideUp() {
        let homePlanetImageView = view.viewWithTag(100) as! UIImageView
        let loginBottomImageView = view.viewWithTag(101) as! UIImageView

        // Set initial positions for the images
        homePlanetImageView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        loginBottomImageView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)

        // Animate the loginBottomImageView sliding up
        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseInOut) {
            loginBottomImageView.transform = .identity
        }

        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseInOut) {
               homePlanetImageView.transform = .identity
            // Start the hover animation for homePlanetImageView
                self.hoverAnimation(for: homePlanetImageView)
           } completion: { _ in

               // Fade in the Apple Sign In button and Orbit Title
               self.fadeInElements()
           }
    }
    
    func hoverAnimation(for imageView: UIImageView) {
        // Initial upward movement
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse]) {
            imageView.transform = CGAffineTransform(translationX: 0, y: -10)
        } completion: { _ in
            // Reset the transformation
            imageView.transform = .identity
        }
    }
    
    func fadeInElements() {
        let appleSignInButton = view.viewWithTag(102) as! ASAuthorizationAppleIDButton
        let orbitTitleLabel = view.viewWithTag(103) as! UILabel

        // Set initial alpha values for the button and label
        appleSignInButton.alpha = 0
        orbitTitleLabel.alpha = 0

        // Animate the fade-in effect
        UIView.animate(withDuration: 1, delay: 0.25) {
            appleSignInButton.alpha = 1
            orbitTitleLabel.alpha = 1
        }
    }
    
    func closeAnimation(completion: @escaping () -> Void) {
        let homePlanetImageView = view.viewWithTag(100) as! UIImageView
        let loginBottomImageView = view.viewWithTag(101) as! UIImageView
        let appleSignInButton = view.viewWithTag(102) as! ASAuthorizationAppleIDButton
        let orbitTitleLabel = view.viewWithTag(103) as! UILabel

        // Fade out the Apple Sign In button and Orbit Title
        UIView.animate(withDuration: 0.5) {
            appleSignInButton.alpha = 0
            orbitTitleLabel.alpha = 0
        }

        // Slide down the HomePlanet and bottomLogin images
        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseInOut) {
            homePlanetImageView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            loginBottomImageView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        } completion: { _ in
            completion()
        }
    }

    @objc func handleInfoButton() {
        // If overlay is already present, return
        if overlay != nil { return }
        overlay = UIView()
        overlay?.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        overlay?.frame = self.view.bounds
        self.view.addSubview(overlay!)

        let label = UILabel()
        label.text = "Sign-In Help"
        label.textColor = .white
        label.font = UIFont(name: "STIXTwoText_Bold", size: 45)
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 60, width: self.view.bounds.width, height: 50)
        overlay?.addSubview(label)

        let graph1 = UILabel()
        let paragraphStyle1 = NSMutableParagraphStyle()
        paragraphStyle1.lineSpacing = 8
        let attributedString = NSMutableAttributedString(string: "To keep all Orbit users protected as user data privacy is a major aspect of our vision. We have decided as a team to only integrate Apple’s Secure sign-in.")
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle1, range: NSRange(location: 0, length: attributedString.length))
        graph1.attributedText = attributedString
        graph1.textColor = .white
        graph1.font = UIFont(name: "STIXTwoText", size: 18)
        graph1.textAlignment = .center
        graph1.numberOfLines = 4
        graph1.lineBreakMode = .byWordWrapping
        let spacing: CGFloat = 20  // Space between the two labels
        graph1.frame = CGRect(x: 0, y: label.frame.origin.y + label.frame.size.height + spacing, width: self.view.bounds.width, height: 100)
        overlay?.addSubview(graph1)
        
        let graph2 = UILabel()
        let paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.lineSpacing = 8
        let attributedString2 = NSMutableAttributedString(string: "With this, we are keeping all your data within your own personal icloud storage.")
        attributedString2.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle2, range: NSRange(location: 0, length: attributedString2.length))
        graph2.attributedText = attributedString2
        graph2.textColor = .white
        graph2.font = UIFont(name: "STIXTwoText", size: 18)
        graph2.textAlignment = .center
        graph2.numberOfLines = 2
        graph2.lineBreakMode = .byWordWrapping
        graph2.frame = CGRect(x: 0, y: graph1.frame.origin.y + graph1.frame.size.height + spacing, width: self.view.bounds.width, height: 100)
        overlay?.addSubview(graph2)
        
        let graph3 = UILabel()
        let paragraphStyle3 = NSMutableParagraphStyle()
        paragraphStyle3.lineSpacing = 4 // reduce line spacing
        let attributedString3 = NSMutableAttributedString(string: "(Don’t worry, it won’t take up space from your personal iCloud storage)")
        attributedString3.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle3, range: NSRange(location: 0, length: attributedString3.length))
        graph3.attributedText = attributedString3
        graph3.textColor = .white
        graph3.font = UIFont(name: "STIXTwoText", size: 13)
        graph3.textAlignment = .center
        graph3.numberOfLines = 2
        graph3.lineBreakMode = .byWordWrapping
        graph3.frame = CGRect(x: 0, y: graph2.frame.origin.y + graph2.frame.size.height - 30, width: self.view.bounds.width, height: 70)
        overlay?.addSubview(graph3)
        
        let graph4 = UILabel()
        let paragraphStyle4 = NSMutableParagraphStyle()
        paragraphStyle4.lineSpacing = 8
        let attributedString4 = NSMutableAttributedString(string: "If you have more questions about how this works or, need adiditonal help singing in. Please visit the links below.")
        attributedString4.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle4, range: NSRange(location: 0, length: attributedString4.length))
        graph4.attributedText = attributedString4
        graph4.textColor = .white
        graph4.font = UIFont(name: "STIXTwoText", size: 18)
        graph4.textAlignment = .center
        graph4.numberOfLines = 3
        graph4.lineBreakMode = .byWordWrapping
        graph4.frame = CGRect(x: 0, y: graph3.frame.origin.y + graph3.frame.size.height + spacing + 80, width: self.view.bounds.width, height: 100)
        overlay?.addSubview(graph4)
        
        let supportLabel = UILabel()
        supportLabel.text = "Apple Support"
        supportLabel.textColor = .white
        supportLabel.textAlignment = .center
        supportLabel.font = UIFont(name: "STIXTwoText", size: 18)
        supportLabel.frame = CGRect(x: 0, y: self.view.bounds.height - 100, width: self.view.bounds.width, height: 50)
        overlay?.addSubview(supportLabel)

        // Make the label tappable
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSupportURL))
        supportLabel.isUserInteractionEnabled = true
        supportLabel.addGestureRecognizer(tap)
        
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(systemName: "x.square"), for: .normal)
        closeButton.tintColor = .white
        closeButton.frame = CGRect(x: self.view.bounds.width - 60, y: 40, width: 50, height: 50)
        closeButton.addTarget(self, action: #selector(dismissOverlay(_:)), for: .touchUpInside)
        overlay?.addSubview(closeButton)
    }
    @objc func openSupportURL() {
        if let url = URL(string: "https://support.apple.com/en-us/HT211687") {
            UIApplication.shared.open(url)
        }
    }

    @objc func dismissOverlay(_ sender: UIButton) {
        overlay?.removeFromSuperview()
        overlay = nil
    }
}

