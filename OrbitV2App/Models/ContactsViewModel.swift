//
//  ContactsViewModel.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 5/9/23.
//

import Foundation
import UIKit
import Contacts

protocol ContactsViewModelDelegate: AnyObject {
    func didTapAddButtonForContactWithName(_ fullName: String)
    func didTapRemoveButtonForContactWithName(_ fullName: String)
}

class ContactsViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {
    var contacts: [CNContact] = []
    var selectedContacts: [CNContact] = []
    weak var contactsTableView: UITableView?
    weak var delegate: ContactsViewModelDelegate?


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
             let image = UIImage(data: imageData)
             let squareImage = self.squareImage(image: image!, size: CGSize(width: 40, height: 40))
             let circularImage = self.circularImage(image: squareImage)
             cell.contactImageView.image = circularImage
         } else {
             cell.contactImageView.image = UIImage(systemName: "person.circle")
         }
        // Configure the add/remove button
        if selectedContacts.contains(where: { $0.identifier == contact.identifier }) {
            cell.addButton.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        } else {
            cell.addButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        }

        cell.addButtonAction = { [weak self] in
            let fullName = "\(contact.givenName) \(contact.familyName)"
            if let index = self?.selectedContacts.firstIndex(where: { $0.identifier == contact.identifier }) {
                // Remove the contact from selectedContacts if it's already added
                self?.selectedContacts.remove(at: index)
                self?.delegate?.didTapRemoveButtonForContactWithName(fullName)
            } else {
                // Add the contact to selectedContacts if it's not already added
                self?.selectedContacts.append(contact)
                self?.delegate?.didTapAddButtonForContactWithName(fullName)
            }
            // Refresh the table view to update the add/remove button
            tableView.reloadData()
        }
        return cell
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func squareImage(image: UIImage, size: CGSize) -> UIImage {
        let newSize: CGSize
        if image.size.width < image.size.height {
            newSize = CGSize(width: image.size.width, height: image.size.width)
        } else {
            newSize = CGSize(width: image.size.height, height: image.size.height)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func circularImage(image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let clipPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: image.size), cornerRadius: image.size.width/2)
        clipPath.addClip()
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage
    }

}
class ContactCell: UITableViewCell {
    
    var addButtonAction: (() -> Void)?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let contactImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
        contactImageView.layer.cornerRadius = contactImageView.frame.height / 2
        contactImageView.clipsToBounds = true
        
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
