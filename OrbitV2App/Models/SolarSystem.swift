//
//  SolarSystem.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import Foundation

struct SolarSystem {
    var rings: [Ring]
    
    init() {
            let sampleNotifications1 = [
                Notification(title: "Sample 1", body: "This is a sample notification 1.", identifier: "notif1")
            ]

            let sampleNotifications2 = [
                Notification(title: "Sample 2", body: "This is a sample notification 2.", identifier: "notif2")
            ]

            let sampleNotifications3 = [
                Notification(title: "Sample 3", body: "This is a sample notification 3.", identifier: "notif3")
            ]

            let planet1 = Planet(notifications: sampleNotifications1)
            let planet2 = Planet(notifications: sampleNotifications2)
            let planet3 = Planet(notifications: sampleNotifications3)

            let ring1 = Ring(planet: planet1, notificationTimeInterval: 60)
            let ring2 = Ring(planet: planet2, notificationTimeInterval: 120)
            let ring3 = Ring(planet: planet3, notificationTimeInterval: 180)

            self.rings = [ring1, ring2, ring3]
        }
}
