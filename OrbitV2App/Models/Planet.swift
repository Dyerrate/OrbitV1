//
//  Planet.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import Foundation
import UIKit
import CloudKit

class Planet: Hashable {
    let name: String
    let image: String?
    var position: Int?
    var notifications: [UNNotificationRequest]
    var orbitReference: CKRecord.Reference

    init(name: String, imageName: String,position: Int, orbitReference: CKRecord.Reference) {
        self.name = name
        self.image = imageName
        self.position = position
        self.notifications = []
        self.orbitReference = orbitReference
    }
    
    convenience init?(record: CKRecord) {
        // Ensure the keys used here match the keys in your CloudKit database
        guard let name = record["name"] as? String,
              let imageName = record["image"] as? String,
              let positions = record["position"] as? Int,
              let orbitReference = record["orbit"] as? CKRecord.Reference
        else {
            print("failed to setup planet")
            return nil
        }

        self.init(name: name, imageName: imageName,position: positions, orbitReference: orbitReference)
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(orbitReference)
    }
    
    func addNotification(_ notification: UNNotificationRequest) {
        self.notifications.append(notification)
    }
    static func ==(lhs: Planet, rhs: Planet) -> Bool {
        return lhs.name == rhs.name && lhs.orbitReference == rhs.orbitReference
    }
}
