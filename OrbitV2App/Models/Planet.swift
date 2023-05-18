//
//  Planet.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import Foundation
import UIKit

class Planet {
    let name: String
    let image: UIImage?
    var notifications: [UNNotificationRequest]
    let orbit: Orbit

    init(name: String, imageName: String, orbit: Orbit) {
        self.name = name
        self.image = UIImage(named: imageName)
        self.notifications = []
        self.orbit = orbit
    }
    
    func addNotification(_ notification: UNNotificationRequest) {
        self.notifications.append(notification)
    }
}
