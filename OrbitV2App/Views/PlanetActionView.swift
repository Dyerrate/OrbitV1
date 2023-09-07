//
//  PlanetActionView.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/20/23.
//
import UIKit

protocol PlanetActionViewDelegate: AnyObject {
    func planetSelected(planetInfo: Planet)
    func planetActionViewAlertAddContact()
    func updateNavBar(isThere: Int)

}

class PlanetActionView: UIView,UITextViewDelegate, UIScrollViewDelegate,ContactsViewModelDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, NotificationCellDelegate {
    // *-------------- PROPERTY BREAK --------------*
    private var currentPlanet: Planet?
    var notifications: [Notification]
    private let panelViews: [UIView]
    let notificationTypes = ["Events", "Goals", "Contacts"]
    //For new panels
    private let notificationTypePicker = UIPickerView()
    private let categoryTextField = UITextField()
    private let titleTextField = UITextField()
    private let addNotificationButton = UIButton()
    var contactsViewModel: ContactsViewModel?
    let goalsCategoryPicker = UIPickerView()
    let categoryPicker = UIPickerView()
    let descriptionTextView = UITextView()
    var contactsTableView: UITableView!
    let submitButton = BubbleButton(type: .system)
    let cancelButton = BubbleButton(type: .system)
    let titleLabel = UILabel()
    private let editFieldsContainerView = UIView()
    //Delegate to pass functions to parent view
    weak var delegate: PlanetActionViewDelegate?
    //The new View
    private let planetInfoView = UIView()
    let activeNotificationsView = UIView()
    private let editNotificationsView = UIView()
    let categories = ["Outdoor", "Indoor"]
    private let goalsCategoryOptions = ["Short-Term", "Long-Term"]
    var priorityChange: Bool = false
    var changedNotifications: [(action: String, notification: Notification)] = []
    //Notification Info
    var notificationCount: Int?
    // *-------------- START OF SETUP --------------*
     let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }()
    
    //*----- INSIDE OF PLANET-INFO-VIEW -----*
    
    private let notificationTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Notification Type"
        return label
    }()
    private let eventCategoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    let initalFormText: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    let formLayout: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor.orbitBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let planetNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let planetOrbitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "STIXTwoText_Bold", size: 60)
        label.textAlignment = .center
        return label
    }()
    private let planetOrbit: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "STIXTwoText", size: 20)
        label.textAlignment = .center
        return label
    }()
    private let infoSupport: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "STIXTwoText", size: 20)
        label.textAlignment = .center
        return label
    }()
    private let countTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "STIXTwoText", size: 20)
        label.textAlignment = .center
        return label
    }()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    var typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "StarcruiserExpandedSemi-Italic", size: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let addNotificationTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    private var countIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private var contactIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private var trophyIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private var eventIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private var squareIcon1: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private var squareIcon2: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let floatingPanel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.objectPrimary
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowColor = UIColor.darkGray.cgColor
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
    
    func checkNotificationCount() -> Int {
        let priorityPosition: Int = notifications.count + 1
        if priorityPosition > 15 {
            delegate?.planetActionViewAlertAddContact()
        } else {
            return priorityPosition
        }
        return 0
    }
    
    func didTapAddButtonForContactWithName(_ fullName: String) {
        let thisPriority: Int = checkNotificationCount()
        // Create a new Notification object
        if notifications.contains(where: { $0.title == "\(fullName)" }) {
            // If the title already exists, show an alert and do not add the notification
            delegate?.planetActionViewAlertAddContact()
        } else {
            // If the title does not exist, create a new Notification object
            let newNotification = Notification(type: "Contact", title: "\(fullName)", description: "Contact \(fullName)", priority: thisPriority)
            // Add the notification to your notifications array
            notifications.append(newNotification)
            changedNotifications.append((action: "add", notification: newNotification))
            // Call the method to update the notifications
            updateNotifications()
        }
    }
    
    func updateNotifications() {
        // This is a placeholder for the method that updates the notifications in the PANEL(2/3) method.
        // The exact implementation depends on how the PANEL(2/3) method is defined.
        let imageName: String
        if let notificationCount = notifications.count  as Int?{
            imageName = "\(notificationCount).square"
        } else {
            imageName = "0.square" // replace with your default image name
        }
        print("reset the imageName here: ", imageName)
        countIcon.image = UIImage(systemName: imageName)
        for notification in notifications {
            switch notification.type {
            case "Contact":
                contactIcon.isHidden = false
            case "Event":
                squareIcon2.isHidden = false
                eventIcon.isHidden = false
            case "Goal":
                squareIcon1.isHidden = false
                trophyIcon.isHidden = false
            default:
                print("here ya are: ",notification.type)
                continue
            }
        }
        tableView.reloadData()
        
    }

    func didTapRemoveButtonForContactWithName(_ fullName: String) {
        // Handle the removal of the contact here.
        // You can find the corresponding Notification in your notifications array and remove it.
        if let index = notifications.firstIndex(where: { $0.title.contains(fullName) && $0.type == "Contact" }) {
            notifications.remove(at: index)
        }
        updateNotifications()
    }
    
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
    
    private func setupContactsTableView() {
        contactsTableView = UITableView()
        contactsTableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        contactsViewModel = ContactsViewModel(tableView: self.contactsTableView)
        contactsViewModel!.delegate = self
        contactsTableView.dataSource = contactsViewModel
        contactsTableView.delegate = contactsViewModel
        contactsTableView.isHidden = true
        contactsTableView.layer.cornerRadius = 20
        editNotificationsView.addSubview(contactsTableView)
        contactsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contactsTableView.leadingAnchor.constraint(equalTo: editNotificationsView.leadingAnchor, constant: 15),
            contactsTableView.trailingAnchor.constraint(equalTo: editNotificationsView.trailingAnchor, constant: -15),
            contactsTableView.topAnchor.constraint(equalTo: addNotificationTitle.bottomAnchor, constant: 65),
            contactsTableView.bottomAnchor.constraint(equalTo: editNotificationsView.bottomAnchor, constant: -35)
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
        let thisPriority: Int = checkNotificationCount()
        guard let titleText = titleTextField.text, let descriptionText = descriptionTextView.text else {
            print("Title or Description is empty.")
            return
        }
        // Determine the type from the selected icon
        var type: String
        switch typeLabel.text {
        case "Event Type":
            type = "Event"
        case "Goal Type":
            type = "Goal"
        default:
            print("Invalid Type.")
            return
        }
        let newNotification = Notification(type: type, title: "\(titleText)", description: "\(descriptionText)", priority: thisPriority)
        notifications.append(newNotification)
        changedNotifications.append((action: "add", notification: newNotification))
        clearTitleAndDescriptionFields()
        updateNotifications()
    }
    @objc private func handleCancelButton() {
        print("canceled")
        titleTextField.text = ""
        descriptionTextView.text = ""
        // Handle cancel button action here
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            // Handle tableView scrolling, then return
            return
        }
        let viewWidth = scrollView.bounds.width
        let currentPage = Int(round(scrollView.contentOffset.x / viewWidth))
        pageControl.currentPage = currentPage
        var isThere: Int

        switch currentPage {
        case 0: // planetInfoView
            isThere = 0
            delegate?.updateNavBar(isThere: isThere)
            planetNameLabel.isHidden = false
            editFieldsContainerView.isHidden = true
        case 1: //activeNotificationsView
            isThere = 1
            delegate?.updateNavBar(isThere: isThere)
        case 2: // editNotificationsView
            planetNameLabel.isHidden = true
            editFieldsContainerView.isHidden = false
            isThere = 0
            delegate?.updateNavBar(isThere: isThere)
        default: // other views
            planetNameLabel.isHidden = true
            editFieldsContainerView.isHidden = true
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        planetNameLabel.center = CGPoint(x: planetInfoView.bounds.width / 2, y: planetInfoView.bounds.height / 2)
    }
    func updateTappedPlanetInfo(planet: Planet, notificationList: [Notification]) {
        currentPlanet = planet
        notifications = notificationList
        setPlanetInfo()
    }
    
    
    private func  setPlanetInfo() {
        switch currentPlanet?.position {
        case 1:
            planetOrbitLabel.text = "1 - 5 Days"
        case 2:
            planetOrbitLabel.text = "1 - 2 Weeks"
        case 3:
            planetOrbitLabel.text = "1 Month"
        default:
            planetOrbitLabel.text = "Error"
        }
    }
    
    func updatePlanetName(planetName: String?) {
        if let name = planetName {
            planetNameLabel.text = "\(name)"
        }
    }
    // *-------------- END OF SETUP --------------*
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

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

    private func clearTitleAndDescriptionFields() {
        titleTextField.text = ""
        descriptionTextView.text = ""
        // Force the layout of subviews immediately and then update the display.
        titleTextField.setNeedsLayout()
        titleTextField.layoutIfNeeded()
        descriptionTextView.setNeedsLayout()
        descriptionTextView.layoutIfNeeded()
    }
    
    init(frame: CGRect, notifications: [Notification]) {
        self.notifications = notifications
        notificationCount = notifications.count
        panelViews = [planetInfoView, activeNotificationsView, editNotificationsView]
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        setupFloatingPanel()
        // Rest of your setup code
    }
    required init?(coder aDecoder: NSCoder) {
        self.notifications = []
        self.panelViews = [planetInfoView, activeNotificationsView, editNotificationsView]
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implmeented")
        // Rest of your setup code
    }
    
    private func addIconRow(notifications: [Notification]) {
        let imageName: String
        if let notificationCount = notificationCount {
            imageName = "\(notificationCount).square"
        } else {
            imageName = "0.square" // replace with your default image name
        }
        countIcon = UIImageView(image: UIImage(systemName: imageName))
        contactIcon = UIImageView(image: UIImage(systemName: "person.crop.square"))
        trophyIcon = UIImageView(image: UIImage(systemName: "trophy.fill"))
        eventIcon = UIImageView(image: UIImage(systemName: "party.popper.fill"))
        // Create containers for the combined icons
        squareIcon1 = UIImageView(image: UIImage(systemName: "square"))
        squareIcon2 = UIImageView(image: UIImage(systemName: "square"))
        squareIcon1.addSubview(trophyIcon)
        squareIcon2.addSubview(eventIcon)
        countIcon.contentMode = .scaleAspectFit
        contactIcon.contentMode = .scaleAspectFit
        trophyIcon.contentMode = .scaleAspectFit
        eventIcon.contentMode = .scaleAspectFit
        squareIcon1.contentMode = .scaleAspectFit
        squareIcon2.contentMode = .scaleAspectFit
        countIcon.tintColor = .systemRed
        squareIcon2.tintColor = .green
        trophyIcon.tintColor = .yellow
        squareIcon1.tintColor = .white
        eventIcon.tintColor = .white
        squareIcon1.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        squareIcon2.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        countIcon.transform = CGAffineTransform(scaleX: 1.6, y:1.6)
        contactIcon.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        // Create the separator
        let separator = UILabel()
        separator.text = "|"
        // Create the stack view and add the icons to it
        let stackView = UIStackView(arrangedSubviews: [countIcon, separator, contactIcon, squareIcon1, squareIcon2])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        trophyIcon.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        eventIcon.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        // Add the stack view to the planetInfoView
        planetInfoView.addSubview(stackView)
        // Add constraints to position the stack view below countTitle
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: planetInfoView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: countTitle.bottomAnchor, constant: 5),// Increase size as needed
            trophyIcon.centerXAnchor.constraint(equalTo: squareIcon1.centerXAnchor),
            trophyIcon.centerYAnchor.constraint(equalTo: squareIcon1.centerYAnchor),
            eventIcon.centerXAnchor.constraint(equalTo: squareIcon2.centerXAnchor),
            eventIcon.centerYAnchor.constraint(equalTo: squareIcon2.centerYAnchor)
        ])
        contactIcon.isHidden = true
        squareIcon1.isHidden = true
        squareIcon2.isHidden = true
        eventIcon.isHidden = true
        trophyIcon.isHidden = true
        
        for notification in notifications {
            switch notification.type {
            case "Contact":
                contactIcon.isHidden = false
            case "Event":
                squareIcon2.isHidden = false
                eventIcon.isHidden = false
            case "Goal":
                squareIcon1.isHidden = false
                trophyIcon.isHidden = false
            default:
                print("here ya are: ",notification.type)
                continue
            }
        }
        var visibleIconsCount = 0
        if !contactIcon.isHidden { visibleIconsCount += 1 }
        if !squareIcon1.isHidden { visibleIconsCount += 1 }
        if !squareIcon2.isHidden { visibleIconsCount += 1 }

        // Adjust the spacing
        if visibleIconsCount == 1 {
            stackView.widthAnchor.constraint(equalTo: planetInfoView.widthAnchor, multiplier: 0.15).isActive = true
        } else if visibleIconsCount == 2 {
            stackView.widthAnchor.constraint(equalTo: planetInfoView.widthAnchor, multiplier: 0.31).isActive = true
        } else {
            stackView.widthAnchor.constraint(equalTo: planetInfoView.widthAnchor, multiplier: 0.4).isActive = true
        }

    }
    //PANEL(1/3)
    private func setupPlanetInfoView() {
        planetInfoView.backgroundColor = .clear
        planetInfoView.translatesAutoresizingMaskIntoConstraints = false
        planetNameLabel.font = UIFont(name: "StarcruiserExpandedSemi-Italic", size: 45)
        planetNameLabel.textColor = UIColor.white
        planetNameLabel.translatesAutoresizingMaskIntoConstraints = false
        planetInfoView.addSubview(planetNameLabel)
        planetOrbit.textColor = UIColor.panelFont
        planetOrbit.text = "Orbit:"
        planetOrbit.translatesAutoresizingMaskIntoConstraints = false
        planetInfoView.addSubview(planetOrbit)
        planetOrbitLabel.textColor = .white
        planetOrbitLabel.translatesAutoresizingMaskIntoConstraints = false
        planetInfoView.addSubview(planetOrbitLabel)
        countTitle.textColor = UIColor.panelFont
        countTitle.text = "Quick View"
        countTitle.translatesAutoresizingMaskIntoConstraints = false
        planetInfoView.addSubview(countTitle)
        addIconRow(notifications: notifications)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "Swipe to the right to view more.."
        instructionLabel.textColor = UIColor.panelFont
        instructionLabel.font = UIFont(name: "STIXTwoText", size: 20)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        planetInfoView.addSubview(instructionLabel)

        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "arrow.right") // Assuming you want to use SF Symbols
        arrowImageView.tintColor = .white
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        planetInfoView.addSubview(arrowImageView)
        NSLayoutConstraint.activate([
            planetNameLabel.centerXAnchor.constraint(equalTo: planetInfoView.centerXAnchor),
            planetNameLabel.topAnchor.constraint(equalTo: planetInfoView.topAnchor, constant: 25),

            planetOrbit.centerXAnchor.constraint(equalTo: planetInfoView.centerXAnchor),
            planetOrbit.topAnchor.constraint(equalTo: planetNameLabel.bottomAnchor, constant: 129), // Space of 10 points below planetNameLabel
            
            planetOrbitLabel.centerXAnchor.constraint(equalTo: planetInfoView.centerXAnchor),
            planetOrbitLabel.topAnchor.constraint(equalTo: planetOrbit.bottomAnchor, constant: 3), // Space of 10 points below planetOrbit

            countTitle.centerXAnchor.constraint(equalTo: planetInfoView.centerXAnchor),
            countTitle.topAnchor.constraint(equalTo: planetOrbitLabel.bottomAnchor, constant: 88),

            instructionLabel.centerXAnchor.constraint(equalTo: planetInfoView.centerXAnchor),
            instructionLabel.bottomAnchor.constraint(equalTo: planetInfoView.bottomAnchor, constant: -40), // 20 points padding from the bottom

            arrowImageView.centerXAnchor.constraint(equalTo: planetInfoView.centerXAnchor),
            arrowImageView.bottomAnchor.constraint(equalTo: instructionLabel.topAnchor, constant: -5) // 10 points above instructionLabel
        ])
    }
    
    // PANEL(2/3)
    private func setupActiveNotificationsView() {
        activeNotificationsView.backgroundColor = UIColor.clear
        let headerLabel = UILabel()
        headerLabel.font = UIFont(name: "StarcruiserExpandedSemi-Italic", size: 25)
        headerLabel.numberOfLines = 0 // Allows the label to have multiple lines
        headerLabel.text = "Active \nNotifications" // Sets the label text
        headerLabel.textAlignment = .center // Centers the text
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        // Add the tableView to the view
        activeNotificationsView.addSubview(headerLabel)
        tableView.layer.cornerRadius = 20
        activeNotificationsView.addSubview(tableView)
        
        // Add layout constraints
        NSLayoutConstraint.activate([
            // HeaderLabel constraints
            headerLabel.topAnchor.constraint(equalTo: activeNotificationsView.topAnchor, constant: 5),
            headerLabel.leadingAnchor.constraint(equalTo: activeNotificationsView.leadingAnchor, constant: 5),
            headerLabel.trailingAnchor.constraint(equalTo: activeNotificationsView.trailingAnchor, constant: -5),

            // TableView constraints
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 35),
            tableView.leadingAnchor.constraint(equalTo: activeNotificationsView.leadingAnchor, constant: 15),
            tableView.trailingAnchor.constraint(equalTo: activeNotificationsView.trailingAnchor, constant: -15),
            tableView.bottomAnchor.constraint(equalTo: activeNotificationsView.bottomAnchor, constant: -30)
        ])
        // Set the dataSource and delegate
        tableView.dataSource = self
        tableView.delegate = self
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if tableView == contactsTableView && !tableView.isEditing {
            return nil
        }
        // Allow selection for other cases
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notificationToRemove: Notification = notifications[indexPath.row]
            notifications.remove(at: indexPath.row)
            changedNotifications.append((action: "delete", notification: notificationToRemove))
            priorityChange = true
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateNotifications()
        }
        for (index, notification) in notifications.enumerated() {
            notification.priority = index + 1
        }
        notifications.sort() {$0.priority < $1.priority}
        // Reload the table view to reflect the updated priorities
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.delegate = self
        notifications.sort() {$0.priority < $1.priority}
        let notification = notifications[indexPath.row]
        let icon: UIImage?
        switch notification.type {
            case "Event":
            icon = UIImage(systemName: "party.popper.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            
            case "Goal":
                icon = UIImage(systemName: "trophy.fill")?.withTintColor(.yellow, renderingMode: .alwaysOriginal)
            case "Contact":
                icon = UIImage(systemName: "person.crop.square")
            default:
                icon = nil
            }
        let priorityString = String(notification.priority)

        // Populate the cell with data from the notification
        cell.titleLabel.text = notification.title  // replace with actual property name
        cell.iconView.image = icon // add the image from your notification data
        cell.priorityLabel.text = priorityString
        
        return cell
    }

    // MARK: - UITableViewDelegate

    // Enable row moving
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.notifications[sourceIndexPath.row]
        notifications.remove(at: sourceIndexPath.row)
        notifications.insert(movedObject, at: destinationIndexPath.row)
        // Update the priority for all notifications based on their new positions
        for (index, notification) in notifications.enumerated() {
            notification.priority = index + 1
        }
        notifications.sort() {$0.priority < $1.priority}
        // Reload the table view to reflect the updated priorities
        priorityChange = true
        tableView.reloadData()
    }
    func notificationCellDidTapIcon(_ cell: NotificationCell) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    func updateNotificationPriorities() {
        notifications.sort() {$0.priority < $1.priority}
        tableView.reloadData()  // Refresh the tableView to reflect the changes
    }
    //PANEL(3/3)
    private func setupEditNotificationsView() {
        editNotificationsView.addSubview(formLayout)
        editNotificationsView.backgroundColor = UIColor.clear
        editNotificationsView.layer.cornerRadius = 2
        
        // Notification Type Label
        addNotificationTitle.text = "Add \nNotification"
        addNotificationTitle.numberOfLines = 0
        addNotificationTitle.font = UIFont(name: "StarcruiserExpandedSemi-Italic", size: 25)
        addNotificationTitle.textColor = .white
        editNotificationsView.addSubview(addNotificationTitle)
        NSLayoutConstraint.activate([
            addNotificationTitle.centerXAnchor.constraint(equalTo: editNotificationsView.centerXAnchor),
            addNotificationTitle.topAnchor.constraint(equalTo: editNotificationsView.safeAreaLayoutGuide.topAnchor, constant: 5)
        ])
        let contactIcon = UIImageView(image: UIImage(systemName: "person.crop.square"))
        let trophyIcon = UIImageView(image: UIImage(systemName: "trophy.fill"))
        let eventIcon = UIImageView(image: UIImage(systemName: "party.popper.fill"))
        // Create containers for the combined icons
        let squareIcon1 = UIImageView(image: UIImage(systemName: "square"))
        let squareIcon2 = UIImageView(image: UIImage(systemName: "square"))
        squareIcon1.addSubview(trophyIcon)
        squareIcon2.addSubview(eventIcon)
        contactIcon.contentMode = .scaleAspectFit
        trophyIcon.contentMode = .scaleAspectFit
        eventIcon.contentMode = .scaleAspectFit
        squareIcon1.contentMode = .scaleAspectFit
        squareIcon2.contentMode = .scaleAspectFit
        squareIcon2.tintColor = .green
        trophyIcon.tintColor = .yellow
        squareIcon1.tintColor = .white
        eventIcon.tintColor = .white
        squareIcon1.transform = CGAffineTransform(scaleX: 2.25, y: 1.5)
        squareIcon2.transform = CGAffineTransform(scaleX: 2.25, y: 1.5)
        contactIcon.transform = CGAffineTransform(scaleX: 2.25, y: 1.5)
        contactIcon.tag = 1
        squareIcon1.tag = 2
        squareIcon2.tag = 3
        
        let iconStack = UIStackView(arrangedSubviews: [contactIcon, squareIcon1, squareIcon2])
        iconStack.axis = .horizontal
        iconStack.distribution = .equalSpacing
        iconStack.translatesAutoresizingMaskIntoConstraints = false
        iconStack.transform = CGAffineTransform(scaleX: 1.1, y: 1.6)
        trophyIcon.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        eventIcon.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        // Add the stack view to the planetInfoView
        editNotificationsView.addSubview(iconStack)
        // Add constraints to position the stack view below countTitle
        NSLayoutConstraint.activate([
            iconStack.centerXAnchor.constraint(equalTo: editNotificationsView.centerXAnchor),
            iconStack.topAnchor.constraint(equalTo: addNotificationTitle.bottomAnchor, constant: 15),// Increase size as needed
            iconStack.leadingAnchor.constraint(equalTo: editNotificationsView.leadingAnchor, constant: 60), // Adjust the constant as needed
            iconStack.trailingAnchor.constraint(equalTo: editNotificationsView.trailingAnchor, constant: -50), // Adjust the constant as needed
            trophyIcon.centerXAnchor.constraint(equalTo: squareIcon1.centerXAnchor),
            trophyIcon.centerYAnchor.constraint(equalTo: squareIcon1.centerYAnchor),
            eventIcon.centerXAnchor.constraint(equalTo: squareIcon2.centerXAnchor),
            eventIcon.centerYAnchor.constraint(equalTo: squareIcon2.centerYAnchor)
        ])
         // Make sure the icons were successfully created before adding the gesture recognizers
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(iconTapped))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(iconTapped))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(iconTapped))

        contactIcon.addGestureRecognizer(tapGesture1)
        squareIcon1.addGestureRecognizer(tapGesture2)
        squareIcon2.addGestureRecognizer(tapGesture3)

        contactIcon.isUserInteractionEnabled = true
        squareIcon1.isUserInteractionEnabled = true
        squareIcon2.isUserInteractionEnabled = true
        
        //Initial Text
        initalFormText.text = "Tap \n An Icon"
        initalFormText.font = UIFont(name: "StarcruiserExpandedSemi-Italic", size: 25)
        initalFormText.numberOfLines = 3
        editNotificationsView.addSubview(initalFormText)
        
        // Title Label
        titleLabel.text = "Title"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .white
        formLayout.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Title UITextField
        titleTextField.borderStyle = .roundedRect
        formLayout.addSubview(titleTextField)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false

        // Description Label
        descriptionLabel.text = "Description"
        descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        descriptionLabel.textColor = .white
        formLayout.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Description UITextView
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 1
        formLayout.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        formLayout.addSubview(typeLabel)
        NSLayoutConstraint.activate([
            initalFormText.centerXAnchor.constraint(equalTo: editNotificationsView.centerXAnchor),
            initalFormText.centerYAnchor.constraint(equalTo: editNotificationsView.centerYAnchor),
            // Form Layout constraints
            formLayout.leadingAnchor.constraint(equalTo: editNotificationsView.leadingAnchor, constant: 16),
            formLayout.trailingAnchor.constraint(equalTo: editNotificationsView.trailingAnchor, constant: -16),
            formLayout.topAnchor.constraint(equalTo: iconStack.bottomAnchor, constant: 20),// Sit above the submit/cancel buttons
            // Type Label constraints
            typeLabel.centerXAnchor.constraint(equalTo: formLayout.centerXAnchor),
            typeLabel.topAnchor.constraint(equalTo: formLayout.topAnchor, constant: 8),
            // Adjust the other top constraints to position the elements below the typeLabel
            titleLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 15),
            // Title Label constraints
            titleLabel.centerXAnchor.constraint(equalTo: formLayout.centerXAnchor),
            // Title UITextField constraints
            titleTextField.leadingAnchor.constraint(equalTo: formLayout.leadingAnchor, constant: 25), // Add padding
            titleTextField.trailingAnchor.constraint(equalTo: formLayout.trailingAnchor, constant: -25), // Add padding
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.5),
            // Description Label constraints
            descriptionLabel.centerXAnchor.constraint(equalTo: formLayout.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            // Description UITextView constraints
            descriptionTextView.leadingAnchor.constraint(equalTo: formLayout.leadingAnchor, constant: 16), // Add padding
            descriptionTextView.trailingAnchor.constraint(equalTo: formLayout.trailingAnchor, constant: -16), // Add padding
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            descriptionTextView.bottomAnchor.constraint(equalTo: formLayout.bottomAnchor, constant: -15), // Add padding
        ])
        //Listeners
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        titleTextField.returnKeyType = .done
        descriptionTextView.returnKeyType = .done
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        // Submit Button

        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        submitButton.backgroundColor = UIColor.gray
        submitButton.layer.cornerRadius = 10
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.addTarget(self, action: #selector(handleSubmitButton), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        submitButton.addTarget(self, action: #selector(buttonTouchUp), for: .touchUpInside)
        editNotificationsView.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.isEnabled = false

        // Cancel Button
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.layer.cornerRadius = 10
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        cancelButton.addTarget(self, action: #selector(buttonTouchUp), for: .touchUpInside)
        editNotificationsView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: editNotificationsView.leadingAnchor, constant: 16),
            submitButton.bottomAnchor.constraint(equalTo: editNotificationsView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            submitButton.widthAnchor.constraint(equalToConstant: 50), // Set your desired width
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.leadingAnchor.constraint(equalTo: submitButton.trailingAnchor, constant: 8),
            cancelButton.trailingAnchor.constraint(equalTo: editNotificationsView.trailingAnchor, constant: -16),
            cancelButton.bottomAnchor.constraint(equalTo: editNotificationsView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 50), // Set your desired width
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            formLayout.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20)
        ])
        titleTextField.isHidden = true
        titleLabel.isHidden = true
        formLayout.isHidden = true
        descriptionTextView.isHidden = true
        descriptionLabel.isHidden = true
        submitButton.isHidden = true
        cancelButton.isHidden = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkFormValidity()
    }

    @objc func textViewDidChange(_ textView: UITextView) {
        checkFormValidity()
    }
    
    

    func checkFormValidity() {
        if let titleText = titleTextField.text, !titleText.isEmpty,
           let descriptionText = descriptionTextView.text, !descriptionText.isEmpty {
            submitButton.isEnabled = true
            submitButton.backgroundColor = UIColor.orbitBackground // or any color you want when enabled
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = UIColor.gray // or any color you want when disabled
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func iconTapped(_ sender: UITapGestureRecognizer) {
        guard let iconView = sender.view as? UIImageView else {
            return
        }
        switch iconView.tag {
        case 1:
            // handle contactIcon tap
            print("contacts")
//            clearTitleAndDescriptionFields()
            titleTextField.isHidden = true
            titleLabel.isHidden = true
            formLayout.isHidden = true
            descriptionTextView.isHidden = true
            contactsTableView.isHidden = false
            submitButton.isHidden = true
            cancelButton.isHidden = true
            initalFormText.isHidden = true
        case 2:
            print("goals")
//            categoryTextField.isHidden = false
            animateFormLayout()
            submitButton.isHidden = false
            cancelButton.isHidden = false
            typeLabel.text = "Goal Type"
            titleTextField.isHidden = false
            titleLabel.isHidden = false
            descriptionTextView.isHidden = false
            contactsTableView.isHidden = true
            descriptionLabel.isHidden = false
            initalFormText.isHidden = true

        case 3:
            // handle squareIcon2 tap
            print("events")
            animateFormLayout()
            submitButton.isHidden = false
            typeLabel.text = "Event Type"
            cancelButton.isHidden = false
            titleTextField.isHidden = false
            descriptionLabel.isHidden = false
            titleLabel.isHidden = false
            descriptionTextView.isHidden = false
            contactsTableView.isHidden = true
            initalFormText.isHidden = true

        default:
            break
        }
    }
    //Animation: for formLayout display
    func animateFormLayout() {
        if formLayout.isHidden {
            formLayout.isHidden = false
            formLayout.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            UIView.animate(withDuration: 0.3, animations: {
                self.formLayout.transform = CGAffineTransform.identity
            })
        }
    }
    
}//End of CLASS

class NotificationCell: UITableViewCell {
    weak var delegate: NotificationCellDelegate? // Add a label to the cell

    var titleLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Add an imageView to the cell
    var iconView: UIImageView = {
        var imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var priorityLabel: UILabel = {
       var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Override the initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priorityLabel)
        // Add layout constraints
        NSLayoutConstraint.activate([
            // IconView constraints
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 30), // Or any desired width
            iconView.heightAnchor.constraint(equalToConstant: 30), // Or any desired height
            // TitleLabel constraints
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // PriorityLabel constraints
            priorityLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 20),
            priorityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            priorityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
}
protocol NotificationCellDelegate: AnyObject {
    func notificationCellDidTapIcon(_ cell: NotificationCell)
}

