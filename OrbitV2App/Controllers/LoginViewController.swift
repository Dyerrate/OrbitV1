//
//  LoginViewController.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit

class LoginViewController: UIViewController {
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.orbitBackground
        // Configure emailTextField
          emailTextField.backgroundColor = UIColor.orbitTextFieldBackground
          emailTextField.layer.cornerRadius = 5
          emailTextField.layer.borderWidth = 1
          emailTextField.layer.borderColor = UIColor.systemGray5.cgColor
          emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
          emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailTextField.frame.height))
          emailTextField.leftViewMode = .always

          // Configure passwordTextField
          passwordTextField.backgroundColor = UIColor.orbitTextFieldBackground
          passwordTextField.layer.cornerRadius = 5
          passwordTextField.layer.borderWidth = 1
          passwordTextField.layer.borderColor = UIColor.systemGray5.cgColor
          passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
          passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passwordTextField.frame.height))
          passwordTextField.leftViewMode = .always

          // Configure loginButton
        loginButton.backgroundColor = UIColor.orbitLoginButtonBackground
        loginButton.layer.cornerRadius = 5
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        loginButton.layer.shadowOpacity = 0.2
        loginButton.layer.shadowRadius = 5
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
          // Configure forgotPasswordButton
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.setTitleColor(UIColor.orbitForgotPasswordButtonTitle, for: .normal)
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(UIColor.orbitForgotPasswordButtonTitle, for: .normal)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        let logoImageView = UIImageView(image: UIImage(named: "OrbitLoginLogo"))
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        // Add constraints
        
        // Container view for email, password, and login button
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 5
        
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 230)
        ])
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgotPasswordButton, registerButton])
         stackView.axis = .vertical
         stackView.spacing = 12
         stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
            ])


        // Add constraints
        NSLayoutConstraint.activate([
            
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -30),
            logoImageView.widthAnchor.constraint(equalToConstant: 150), // Set the desired width
            logoImageView.heightAnchor.constraint(equalToConstant: 150),
            
        ])
                                    
    }
    

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),

            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.heightAnchor.constraint(equalToConstant: 44),

            forgotPasswordButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func loginButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.loginButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.loginButton.transform = CGAffineTransform.identity
            }) { _ in
                // Perform your login action here
                self.loginUser()
            }
        }
    }

    @objc private func loginUser() {
        // Authenticate user and call checkNotificationAccess() on success
        let loadingView = SolarSystemViewController()
        
        
    }
    @objc func registerButtonTapped() {
        let registerVC = RegisterViewController()
        let navigationController = UINavigationController(rootViewController: registerVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
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

    @objc private func forgotPassword() {
        // Handle forgot password functionality
    }
}

