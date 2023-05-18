//
//  Notification.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import Foundation
import Contacts

//struct Notification {
//    var title: String, body: String, identifier: String
//}
struct Notification {
    var type: NotificationType
    var title: String
    var description: String
    var date: Date?
    var contacts: [CNContact]?
}

enum NotificationType {
    case event
    case goal
    case contact
}
