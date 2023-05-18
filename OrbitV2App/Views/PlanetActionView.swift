//
//  PlanetActionView.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/20/23.
//
import Contacts
import UIKit

protocol PlanetActionViewDelegate: AnyObject {
    func planetSelected(planetName: String, orbitName: String)
    func viewButtonTapped()
    func editButtonTapped()
    func returnButtonTapped()
}

class PlanetActionView: UIView, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    //For displaying the Views for notifcations
    private let panelViews: [UIView]
    let notificationTypes = ["Events", "Goals", "Contacts"]
    //For new panels
    private let notificationTypePicker = UIPickerView()
    private let categoryTextField = UITextField()
    private let titleTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let dateTextField = UITextField()
    private let addNotificationButton = UIButton()
    var contactsViewModel: ContactsViewModel?
    
    let goalsCategoryPicker = UIPickerView()
    let categoryPicker = UIPickerView()
    let descriptionTextView = UITextView()
    var contactsTableView: UITableView!
    let cancelButton = BubbleButton(type: .system)
    let titleLabel = UILabel()


    
    private let editFieldsContainerView = UIView()
    
    //Delegate to pass functions to parent view
    weak var delegate: PlanetActionViewDelegate?
    
    //The new View
    private let planetInfoView = UIView()
    private let activeNotificationsView = UIView()
    private let editNotificationsView = UIView()
    
    
   // *-------------- PROPERTY BREAK --------------*
    
    
    // *-------------- START OF SETUP --------------*
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }()
    
    //*----- INSIDE OF PLANET-INFO-VIEW -----*
    
    private let orbitNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    private let notificationTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Notification Type"
        return label
    }()
    
    private let planetNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    
    private let floatingPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .spacePurple1
        view.layer.cornerRadius = 20
        return view
    }()
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 3
        control.currentPageIndicatorTintColor = .white
        control.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        return control
    }()
    
    private func setupFloatingPanel() {
        addSubview(floatingPanel)
        floatingPanel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        NSLayoutConstraint.activate([
            floatingPanel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            floatingPanel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            floatingPanel.heightAnchor.constraint(equalToConstant: bounds.height),
            floatingPanel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        floatingPanel.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: floatingPanel.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: floatingPanel.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: floatingPanel.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: floatingPanel.bottomAnchor)
        ])
        setupPageControl()
        setupPlanetInfoView()
        setupActiveNotificationsView()
        setupEditNotificationsView()
        setupContactsTableView()
        scrollView.contentSize = CGSize(width: bounds.width * CGFloat(panelViews.count), height: bounds.height)
        for (index, panelView) in panelViews.enumerated() {
            scrollView.addSubview(panelView)
            panelView.translatesAutoresizingMaskIntoConstraints = false

            var leadingAnchor: NSLayoutXAxisAnchor
            if index == 0 {
                leadingAnchor = scrollView.leadingAnchor
            } else {
                leadingAnchor = panelViews[index - 1].trailingAnchor
            }

            NSLayoutConstraint.activate([
                panelView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                panelView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
                panelView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                panelView.leadingAnchor.constraint(equalTo: leadingAnchor)
            ])
        }
    }
    
    //Control for the dots at the bottom of the panel
    private func setupPageControl() {
        floatingPanel.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: floatingPanel.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: floatingPanel.bottomAnchor, constant: -8)
        ])
    }

    private func setupPlanetInfoView() {
        planetInfoView.backgroundColor = .clear
        planetInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        planetNameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        planetNameLabel.textColor = .white
        planetNameLabel.translatesAutoresizingMaskIntoConstraints = false
        planetInfoView.addSubview(planetNameLabel)
        
        NSLayoutConstraint.activate([
            planetNameLabel.centerXAnchor.constraint(equalTo: planetInfoView.centerXAnchor),
            planetNameLabel.topAnchor.constraint(equalTo: planetInfoView.topAnchor, constant: 10)
        ])
        planetInfoView.addSubview(orbitNameLabel)
        orbitNameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            orbitNameLabel.centerXAnchor.constraint(equalTo: planetInfoView.centerXAnchor),
            orbitNameLabel.topAnchor.constraint(equalTo: planetNameLabel.bottomAnchor, constant: 8)
        ])
    }

    private func setupActiveNotificationsView() {
        activeNotificationsView.backgroundColor = UIColor.clear
        activeNotificationsView.layer.cornerRadius = 20

        // Add active notifications UI elements here
    }

    private func setupEditNotificationsView() {
        editNotificationsView.backgroundColor = UIColor.clear
        editNotificationsView.layer.cornerRadius = 2
        

        // Notification Type Label
        let notificationTypeLabel = UILabel()
        notificationTypeLabel.text = "Notification Type"
        notificationTypeLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        notificationTypeLabel.textColor = .white
        editNotificationsView.addSubview(notificationTypeLabel)
        notificationTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notificationTypeLabel.centerXAnchor.constraint(equalTo: editNotificationsView.centerXAnchor),
            notificationTypeLabel.topAnchor.constraint(equalTo: editNotificationsView.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])

        // UIPickerView
        notificationTypePicker.dataSource = self
        notificationTypePicker.delegate = self
        editNotificationsView.addSubview(notificationTypePicker)
        notificationTypePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notificationTypePicker.centerXAnchor.constraint(equalTo: editNotificationsView.centerXAnchor),
            notificationTypePicker.topAnchor.constraint(equalTo: notificationTypeLabel.bottomAnchor, constant: 5),
            notificationTypePicker.widthAnchor.constraint(equalTo: editNotificationsView.widthAnchor, multiplier: 0.8),
            notificationTypePicker.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        let eventCategoryLabel = UILabel()
        eventCategoryLabel.text = "Event Category"
        eventCategoryLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        eventCategoryLabel.textColor = .white
        editNotificationsView.addSubview(eventCategoryLabel)
        eventCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventCategoryLabel.centerXAnchor.constraint(equalTo: editNotificationsView.centerXAnchor),
            eventCategoryLabel.topAnchor.constraint(equalTo: notificationTypePicker.bottomAnchor, constant: 8)
        ])
        goalsCategoryPicker.delegate = self
        goalsCategoryPicker.dataSource = self
        editNotificationsView.addSubview(goalsCategoryPicker)
        goalsCategoryPicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goalsCategoryPicker.leadingAnchor.constraint(equalTo: editNotificationsView.leadingAnchor, constant: 16),
            goalsCategoryPicker.trailingAnchor.constraint(equalTo: editNotificationsView.trailingAnchor, constant: -16),
            goalsCategoryPicker.topAnchor.constraint(equalTo: notificationTypePicker.bottomAnchor, constant: 8),
            goalsCategoryPicker.heightAnchor.constraint(equalToConstant: 80)
        ])
        

        // Category UIPickerView
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        editNotificationsView.addSubview(categoryPicker)
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryPicker.leadingAnchor.constraint(equalTo: editNotificationsView.leadingAnchor, constant: 16),
            categoryPicker.trailingAnchor.constraint(equalTo: editNotificationsView.trailingAnchor, constant: -16),
            categoryPicker.topAnchor.constraint(equalTo: notificationTypePicker.bottomAnchor, constant: 16),
            categoryPicker.heightAnchor.constraint(equalToConstant: 80)
        ])

        titleLabel.text = "Title"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .white
        editNotificationsView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: editNotificationsView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 8)
        ])

        // Title UITextField
        titleTextField.borderStyle = .roundedRect
        editNotificationsView.addSubview(titleTextField)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: editNotificationsView.trailingAnchor, constant: -16),
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])

        // Description Label
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Description"
        descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        descriptionLabel.textColor = .white
        editNotificationsView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: editNotificationsView.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8)
        ])

        // Description UITextView
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 1
        editNotificationsView.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
               descriptionTextView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
               descriptionTextView.trailingAnchor.constraint(equalTo: editNotificationsView.trailingAnchor, constant: -16),
               descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
               descriptionTextView.heightAnchor.constraint(equalToConstant: 100)
           ])
        // Submit Button
        let submitButton = BubbleButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(handleSubmitButton), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        submitButton.addTarget(self, action: #selector(buttonTouchUp), for: .touchUpInside)
        editNotificationsView.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false

        // Cancel Button
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        cancelButton.addTarget(self, action: #selector(buttonTouchUp), for: .touchUpInside)
        editNotificationsView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: editNotificationsView.leadingAnchor, constant: 16),
            submitButton.bottomAnchor.constraint(equalTo: editNotificationsView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.leadingAnchor.constraint(equalTo: submitButton.trailingAnchor, constant: 8),
            cancelButton.trailingAnchor.constraint(equalTo: editNotificationsView.trailingAnchor, constant: -16),
            cancelButton.bottomAnchor.constraint(equalTo: editNotificationsView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            
            submitButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
        goalsCategoryPicker.isHidden = true
    }
    
    private func setupContactsTableView() {
        contactsTableView = UITableView()
        contactsTableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        contactsViewModel = ContactsViewModel(tableView: contactsTableView)
        contactsTableView.dataSource = contactsViewModel
        contactsTableView.delegate = contactsViewModel
        contactsTableView.isHidden = true
        editNotificationsView.addSubview(contactsTableView)
        contactsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contactsTableView.leadingAnchor.constraint(equalTo: editNotificationsView.leadingAnchor),
            contactsTableView.trailingAnchor.constraint(equalTo: editNotificationsView.trailingAnchor),
            contactsTableView.topAnchor.constraint(equalTo: notificationTypePicker.bottomAnchor),
            contactsTableView.bottomAnchor.constraint(equalTo: editNotificationsView.bottomAnchor)
        ])
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            sender.transform = CGAffineTransform.identity
        }
    }
    
    @objc private func handleSubmitButton() {
        print("submitted")
        // Handle button action here
    }
    @objc private func handleCancelButton() {
        print("canceled")
        // Handle cancel button action here
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let viewWidth = scrollView.bounds.width
        let currentPage = Int(round(scrollView.contentOffset.x / viewWidth))
        let backgroundColors = [UIColor.spacePurple1, UIColor.green, UIColor.blue]

        floatingPanel.backgroundColor = backgroundColors[currentPage]
        pageControl.currentPage = currentPage

        switch currentPage {
        case 0: // planetInfoView
            planetNameLabel.isHidden = false
            orbitNameLabel.isHidden = false
            editFieldsContainerView.isHidden = true
        case 2: // editNotificationsView
            planetNameLabel.isHidden = true
            orbitNameLabel.isHidden = true
            editFieldsContainerView.isHidden = false
        default: // other views
            planetNameLabel.isHidden = true
            orbitNameLabel.isHidden = true
            editFieldsContainerView.isHidden = true
        }
    }
    func updateOrbitName(orbitName: String?) {
        if let name = orbitName {
            orbitNameLabel.text = "Orbit: \(name)"
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        planetNameLabel.center = CGPoint(x: planetInfoView.bounds.width / 2, y: planetInfoView.bounds.height / 2)
    }
    func updatePlanetName(planetName: String?) {
        if let name = planetName {
            planetNameLabel.text = "\"\(name)\""
        }
    }
    // *-------------- END OF SETUP --------------*
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    let categories = ["Outdoor", "Indoor"]
    private let goalsCategoryOptions = ["Short-Term", "Long-Term"]

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == notificationTypePicker {
            return notificationTypes.count
        } else if pickerView == categoryPicker {
            return categories.count
        } else if pickerView == goalsCategoryPicker {
            return goalsCategoryOptions.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == notificationTypePicker {
            return notificationTypes[row]
        } else if pickerView == categoryPicker {
            return categories[row]
        } else if pickerView == goalsCategoryPicker {
            return goalsCategoryOptions[row]
        }
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == notificationTypePicker {
            updateFormFields()
        }
    }
    
    private func updateFormFields() {
        let selectedIndex = notificationTypePicker.selectedRow(inComponent: 0)
        let selectedType = notificationTypes[selectedIndex]
        switch selectedType {
        case "Events":
            print("events")
            clearTitleAndDescriptionFields()
            categoryTextField.isHidden = false
            titleTextField.isHidden = false
            titleLabel.isHidden = false
            descriptionTextView.isHidden = false
            descriptionTextField.isHidden = false
            contactsTableView.isHidden = true
            categoryPicker.isHidden = false
            goalsCategoryPicker.isHidden = true
        case "Goals":
            print("goals")
            categoryTextField.isHidden = false
            titleTextField.isHidden = false
            titleLabel.isHidden = false
            descriptionTextView.isHidden = false
            descriptionTextField.isHidden = false
            contactsTableView.isHidden = true
            categoryPicker.isHidden = true
            goalsCategoryPicker.isHidden = false
            clearTitleAndDescriptionFields()
        case "Contacts":
            print("contacts")
            categoryPicker.isHidden = true
            categoryTextField.isHidden = true
            titleTextField.isHidden = true
            titleLabel.isHidden = true
            goalsCategoryPicker.isHidden = true
            descriptionTextView.isHidden = true
            descriptionTextField.isHidden = true
            contactsTableView.isHidden = false
        default:
            break
        }
    }
    
    private func clearTitleAndDescriptionFields() {
        titleTextField.text = ""
        descriptionTextView.text = ""
        // Force the layout of subviews immediately and then update the display.
        titleTextField.setNeedsLayout()
        titleTextField.layoutIfNeeded()
        descriptionTextView.setNeedsLayout()
        descriptionTextView.layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        panelViews = [planetInfoView, activeNotificationsView, editNotificationsView]
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupFloatingPanel()
//      setupSwipeGestureRecognizers()
    }
    
    //honestly not certain why this is always required yet lol
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

