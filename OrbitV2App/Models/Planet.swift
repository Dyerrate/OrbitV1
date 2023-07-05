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
    var notifications: [CKRecord.Reference]

    init(name: String, imageName: String,position: Int, notifications: [CKRecord.Reference]) {
        self.name = name
        self.image = imageName
        self.position = position
        self.notifications = []
    }
    
    convenience init?(record: CKRecord) {
        // Ensure the keys used here match the keys in your CloudKit database
        guard let name = record["name"] as? String,
              let imageName = record["image"] as? String,
              let positions = record["position"] as? Int,
              let notifications = record["notifications"] as? [CKRecord.Reference]
        else {
            print("failed to setup planet")
            return nil
        }

        self.init(name: name, imageName: imageName,position: positions, notifications: notifications)
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func ==(lhs: Planet, rhs: Planet) -> Bool {
        return lhs.name == rhs.name
    }
}
