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
    let image: UIImage
    var notifications: [UNNotificationRequest]

    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
        self.notifications = []
    }
    
    func addNotification(_ notification: UNNotificationRequest) {
        self.notifications.append(notification)
    }
}
