//
//  User.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/5/23.
//
import Foundation
import CloudKit

struct User {
    var email: String
    var fullName: String
    let uuid: String
    var planets: [CKRecord.Reference] // <-- new

    var dictionaryRepresentation: [String: Any] {
        return [
            "email": email,
            "fullName": fullName,
            "uuid": uuid,
            "planets": planets // <-- new
        ]
    }
    
    init(email: String, fullName: String, uuid: String, planets: [CKRecord.Reference]) { // <-- new
        self.email = email
        self.fullName = fullName
        self.uuid = uuid
        self.planets = planets // <-- new
    }

    init?(dictionary: [String: Any]) {
        guard let email = dictionary["email"] as? String,
              let fullName = dictionary["fullName"] as? String,
              let uuid = dictionary["uuid"] as? String,
              let planets = dictionary["planets"] as? [CKRecord.Reference] // <-- new
        else { return nil }

        self.init(email: email, fullName: fullName, uuid: uuid, planets: planets) // <-- new
    }
}
