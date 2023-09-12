//
//  Notification.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//

import Foundation
import CloudKit

class Notification {
    var type: String
    var title: String
    var image: String?
    var description: String?
    var date: Date?
    var priority: Int
    var recordID: CKRecord.ID?
    var actionTaken: Int?
    
    init(type: String, title: String, image: String?, description: String, date: Date?, priority: Int, recordID: CKRecord.ID?,actionTaken: Int) {
        self.type = type
        self.title = title
        self.image = image
        self.description = description
        self.date = date
        self.priority = priority
        self.recordID = recordID
        self.actionTaken = actionTaken
    }
    
    init(record: CKRecord) {
        self.type = record["notificationType"] as? String ?? ""
        self.title = record["title"] as? String ?? ""
        self.image = record["imageName"] as? String ?? "" // Update this to include the image URL or data if needed
        self.description = record["description"] as? String ?? ""
        self.date = record["date"] as? Date
        self.priority = record["priority"] as? Int ?? 0// Update this if there's a priority field in the record
        self.recordID = record.recordID
        self.actionTaken = record["actionTake"] as? Int ?? 0
    }
    init(type: String, title: String, description: String, priority: Int, actionTaken: Int) {
        self.type = type
        self.title = title
        self.description = description
        self.priority = priority
        self.actionTaken = actionTaken
    }
    
}


