//
//  PlanetActionView.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/20/23.
//

import UIKit

protocol PlanetActionViewDelegate: AnyObject {
    func viewButtonTapped()
    func editButtonTapped()
    func returnButtonTapped()
    
}

class PlanetActionView: UIView {
    //For displaying the Views for notifcations
    private var eventsView: EventsView?
    private var contactsView: ContactsView?
    private var goalsView: GoalsView?
    
    //For making the Edit View buttons
    private var eventsButton: UIButton!
    private var contactsButton: UIButton!
    private var goalsButton: UIButton!
    
    //Delegate to pass functions to parent view
    weak var delegate: PlanetActionViewDelegate?

    private let titleLabel = UILabel()

   // *-------------- PROPERTY BREAK --------------*
    
    // *-------------- START OF SETUP --------------*

    //The three original buttons for delegation of View/Edit and Return
    private let viewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View", for: .normal)
        button.backgroundColor = .orbitRecord
        button.layer.cornerRadius = 20
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.backgroundColor = .orbitRecord
        button.layer.cornerRadius = 20
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    private let returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrowshape.turn.up.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private func setupEditButtons() {
        eventsButton = UIButton(type: .system)
        eventsButton.setTitle("Events", for: .normal)
        eventsButton.addTarget(self, action: #selector(eventsButtonTapped), for: .touchUpInside)
        eventsButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        eventsButton.layer.cornerRadius = 10

        contactsButton = UIButton(type: .system)
        contactsButton.setTitle("Contacts", for: .normal)
        contactsButton.addTarget(self, action: #selector(contactsButtonTapped), for: .touchUpInside)
        contactsButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        contactsButton.layer.cornerRadius = 10

        goalsButton = UIButton(type: .system)
        goalsButton.setTitle("Goals", for: .normal)
        goalsButton.addTarget(self, action: #selector(goalsButtonTapped), for: .touchUpInside)
        goalsButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        goalsButton.layer.cornerRadius = 10
    }
    
   // For the old Display Edit options
    func displayEditOptions() {
        // Set up the views.
        eventsView = EventsView(frame: CGRect(x: 0, y: bounds.height, width: bounds.width, height: bounds.height * 0.6))
        contactsView = ContactsView(frame: CGRect(x: 0, y: bounds.height, width: bounds.width, height: bounds.height * 0.6))
        goalsView = GoalsView(frame: CGRect(x: 0, y: bounds.height, width: bounds.width, height: bounds.height * 0.6))

        eventsView?.isHidden = true
        contactsView?.isHidden = true
        goalsView?.isHidden = true

        addSubview(eventsView!)
        addSubview(contactsView!)
        addSubview(goalsView!)

        // Position the buttons.
        let buttonWidth: CGFloat = 80
        let buttonHeight: CGFloat = 40
        let padding: CGFloat = 20
        let yOffset: CGFloat = bounds.height * 0.4 - buttonHeight - padding

        eventsButton.frame = CGRect(x: bounds.width * 0.5 - padding - buttonWidth, y: yOffset, width: buttonWidth, height: buttonHeight)
        contactsButton.frame = CGRect(x: bounds.width * 0.5 - buttonWidth * 0.5, y: yOffset, width: buttonWidth, height: buttonHeight)
        goalsButton.frame = CGRect(x: bounds.width * 0.5 + padding, y: yOffset, width: buttonWidth, height: buttonHeight)

        addSubview(eventsButton)
        addSubview(contactsButton)
        addSubview(goalsButton)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupButtons()
        setupEditButtons()
    }
    
    //honestly not certain why this is always required yet lol
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Reseting the View/Edit Button to display
    func resetToInitialState() {
        viewButton.isHidden = false
        editButton.isHidden = false
    }
    
    //Removing/Closing every subview for when the user taps a new planet or zooms out
    func removeSubViews() {
        viewButton.removeFromSuperview()
        editButton.removeFromSuperview()
        returnButton.removeFromSuperview()
    }
    
    //The initial call for postioing the buttons on the view
    private func setupButtons() {
        viewButton.addTarget(self, action: #selector(viewButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        addSubview(viewButton)
        addSubview(editButton)
        
        viewButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            viewButton.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            viewButton.widthAnchor.constraint(equalToConstant: 100),
            viewButton.heightAnchor.constraint(equalToConstant: 40),
            
            editButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            editButton.topAnchor.constraint(equalTo: viewButton.bottomAnchor, constant: 10),
            editButton.widthAnchor.constraint(equalToConstant: 100),
            editButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    private func setupReturnButton() {
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        addSubview(returnButton)
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            returnButton.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -16)
        ])
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        self.layoutIfNeeded()
    }
    @objc private func viewButtonTapped() {
        delegate?.viewButtonTapped()
        viewButton.isHidden = true
        setupReturnButton()
    }
    @objc private func editButtonTapped() {
        editButton.isHidden = true
        viewButton.isHidden = true
        setupReturnButton()
        displayEditOptions()
    }
    @objc private func returnButtonTapped() {
        delegate?.returnButtonTapped()
        returnButton.removeFromSuperview()
    }
    @objc private func eventsButtonTapped() {
        print("events tapped in VIEW")
        eventsView?.isHidden = false
        contactsView?.isHidden = true
        goalsView?.isHidden = true
    }

    @objc private func contactsButtonTapped() {
        print("contacts tapped in VIEW")
        eventsView?.isHidden = true
        contactsView?.isHidden = false
        goalsView?.isHidden = true
    }

    @objc private func goalsButtonTapped() {
        print("events tapped in VIEW")
        eventsView?.isHidden = true
        contactsView?.isHidden = true
        goalsView?.isHidden = false
    }
}
