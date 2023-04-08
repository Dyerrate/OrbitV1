//
//  User.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/5/23.
//

import Foundation
struct User {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let phoneNumber: String

    var dictionaryRepresentation: [String: Any] {
        return [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber
        ]
    }
    
    init(email: String, password: String, firstName: String, lastName: String, phoneNumber: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
    }

    init?(dictionary: [String: Any]) {
        guard let email = dictionary["email"] as? String,
            let password = dictionary["password"] as? String,
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let phoneNumber = dictionary["phoneNumber"] as? String
        else { return nil }

        self.init(email: email, password: password, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
    }
}
