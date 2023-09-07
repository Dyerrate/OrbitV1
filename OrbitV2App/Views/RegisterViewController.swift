//
//  RegisterViewController.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // UI elements
    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    let emailTextField = UITextField()
    let phoneNumberTextField = UITextField()
    let passwordTextField = UITextField()
    let confirmPasswordTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.orbitBackground
        
        let inputFields = [
            (firstNameTextField, "First Name"),
            (lastNameTextField, "Last Name"),
            (emailTextField, "Email"),
            (phoneNumberTextField, "Phone Number"),
            (passwordTextField, "Password"),
            (confirmPasswordTextField, "Confirm Password")
        ]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (textField, placeholder) in inputFields {
            let fieldStackView = UIStackView()
            fieldStackView.axis = .vertical
            fieldStackView.spacing = 5
            //the joint icon and text field to be stacked together
            let textFieldAndIconStackView = UIStackView()
            textFieldAndIconStackView.axis = .horizontal
            textFieldAndIconStackView.spacing = 2
            //The icon for each text input
            let imageView = UIImageView()
            imageView.tintColor = .white
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            imageView.contentMode = .scaleAspectFit
            
            switch placeholder {
            case "First Name":
                imageView.image = UIImage(systemName: "person.crop.circle")
            case "Last Name":
                imageView.image = UIImage(systemName: "person.crop.circle.fill")
            case "Email":
                imageView.image = UIImage(systemName: "envelope")
            case "Phone Number":
                imageView.image = UIImage(systemName: "phone")
            case "Password", "Confirm Password":
                imageView.image = UIImage(systemName: "lock")
            default:
                imageView.image = nil
            }
            
            textField.backgroundColor = UIColor.orbitTextFieldBackground
            textField.layer.cornerRadius = 5
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.systemGray5.cgColor
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: textField.frame.height))
            textField.leftViewMode = .always
            textFieldAndIconStackView.addArrangedSubview(imageView)
            textFieldAndIconStackView.addArrangedSubview(textField)
            textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
            fieldStackView.addArrangedSubview(textFieldAndIconStackView)
            stackView.addArrangedSubview(fieldStackView)
        }
        //The submit button
        let submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = UIColor.orbitLoginButtonBackground
        submitButton.layer.cornerRadius = 5
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        //The cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = UIColor.orbitLoginButtonBackground
        cancelButton.layer.cornerRadius = 5
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        view.addSubview(stackView)
        view.addSubview(cancelButton)
        view.addSubview(submitButton)
        //These are the constraints that can adjust the size and postions of the Views.
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Center the submit button horizontally
            cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            cancelButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 35),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Center the submit button horizontally
            submitButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            submitButton.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 10),
            submitButton.heightAnchor.constraint(equalToConstant: 35),
            NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -20).withPriority(.defaultLow)
        ])
    }
    //For canceling registration
    @objc func cancelButtonTapped() {
        if let navigationController = navigationController {
            navigationController.dismiss(animated: true)
        } else {
            print("NavigationController not found.")
        }
    }
    
    // Add your input check functions here
    @objc func submitButtonTapped() {
        if validateInput() {
            // Save user data
            if let firstName = firstNameTextField.text,
               let lastName = lastNameTextField.text,
               let email = emailTextField.text,
               let phoneNumber = phoneNumberTextField.text,
               let password = passwordTextField.text {
                
                saveUserData(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, password: password)
                
                // Return to login view
                if let navigationController = navigationController {
                    navigationController.dismiss(animated: true)
                } else {
                    print("NavigationController not found.")
                }
            }
        }
    }
    func validateInput() -> Bool {
        var isValid = true
        
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            isValid = false
            // Display error for first name field
            firstNameTextField.text = ""
            firstNameTextField.attributedPlaceholder = NSAttributedString(string: "First Name is required", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        
        if lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            isValid = false
            // Display error for last name field
            lastNameTextField.text = ""
            lastNameTextField.attributedPlaceholder = NSAttributedString(string: "Last Name is required", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        
        if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.contains("@") {
            isValid = false
            // Display error for email field
            emailTextField.text = ""
            emailTextField.attributedPlaceholder = NSAttributedString(string: "You did not enter a proper email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        
        if let phoneNumber = phoneNumberTextField.text, !isValidPhoneNumber(phoneNumber: phoneNumber) {
            isValid = false
            // Display error for phone number field
            phoneNumberTextField.text = ""
            phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "Phone number is required", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        
        if let password = passwordTextField.text, !isValidPassword(password: password) {
            isValid = false
            // Display error for password field
            passwordTextField.text = ""
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password incorecct", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        
        if passwordTextField.text != confirmPasswordTextField.text {
            isValid = false
            // Display error for confirm password field
            
            confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Passwords do not match", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        
        return isValid
    }
    
    func isValidPassword(password: String) -> Bool {
        // Password validation regex: at least one uppercase, one lowercase, one digit, one special character, minimum 8 characters
        let passwordPattern = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[@#$%^&+=!])(?=\\S+$).{8,}"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordPattern)
        return passwordPredicate.evaluate(with: password)
    }
    
    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let phoneNumberPattern = "^[0-9]{10}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberPattern)
        return phoneNumberPredicate.evaluate(with: phoneNumber)
    }
    
    func saveUserData(firstName: String, lastName: String, email: String, phoneNumber: String, password: String) {
//        let user = User(email: email, password: password, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
//
//        UserManager.shared.registerUser(user: user) { (success, error) in
//            if success {
//                print("User registration successful")
//            } else if let error = error {
//                print("User registration failed: \(error.localizedDescription)")
//            }
//        }
    }
}
    
    extension NSLayoutConstraint {
        func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
            self.priority = priority
            return self
        }
    }

