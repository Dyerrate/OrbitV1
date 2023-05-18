//
//  ContactsViewModel.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 5/9/23.
//

import Foundation
import UIKit
import Contacts

class ContactsViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {
    var contacts: [CNContact] = []
    var selectedContacts: [CNContact] = []
    weak var contactsTableView: UITableView?

    init(tableView: UITableView) {
        self.contactsTableView = tableView
        super.init()
        fetchContacts()
    }

    // Fetch contacts from the Contacts framework
    func fetchContacts() {
        DispatchQueue.global(qos: .background).async {
            let store = CNContactStore()

            store.requestAccess(for: .contacts) { (granted, error) in
                if let error = error {
                    print("Failed to request access", error)
                    return
                }

                if granted {
                    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey] as [CNKeyDescriptor]
                    let request = CNContactFetchRequest(keysToFetch: keysToFetch)

                    do {
                        try store.enumerateContacts(with: request) { (contact, stopPointer) in
                            self.contacts.append(contact)
                        }

                        // Once contacts are fetched, reload the table view on the main thread
                        DispatchQueue.main.async {
                            self.contactsTableView?.reloadData()
                        }
                    } catch let error {
                        print("Failed to enumerate contacts: ", error)
                    }
                } else {
                    print("Access denied")
                }
            }
        }
    }

    // Implement UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        let contact = contacts[indexPath.row]

        // Configure the cell with contact data
        cell.nameLabel.text = contact.givenName + " " + contact.familyName
        if let imageData = contact.imageData {
            cell.contactImageView.image = UIImage(data: imageData)
        }

        // Configure the add/remove button
        if selectedContacts.contains(where: { $0.identifier == contact.identifier }) {
            cell.addButton.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        } else {
            cell.addButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        }

        cell.addButtonAction = { [weak self] in
            if let index = self?.selectedContacts.firstIndex(where: { $0.identifier == contact.identifier }) {
                // Remove the contact from selectedContacts if it's already added
                self?.selectedContacts.remove(at: index)
            } else {
                // Add the contact to selectedContacts if it's not already added
                self?.selectedContacts.append(contact)
            }

            // Refresh the table view to update the add/remove button
            tableView.reloadData()
        }

        return cell
    }
}
class ContactCell: UITableViewCell {
    
    var addButtonAction: (() -> Void)?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let contactImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(contactImageView)
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            contactImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            contactImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contactImageView.widthAnchor.constraint(equalToConstant: 40),
            contactImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: contactImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    @objc func didTapAddButton() {
        addButtonAction?()
    }
}
