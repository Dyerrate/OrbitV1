//
//  Orbit.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 5/2/23.
//

import Foundation
import CloudKit

class Orbit {
    let name: String
    let width: CGFloat
    let height: CGFloat

    init(name: String, width: CGFloat, height: CGFloat) {
        self.name = name
        self.width = width
        self.height = height
    }
    
    convenience init?(record: CKRecord) {
        guard let name = record["name"] as? String,
              let width = record["width"] as? CGFloat,
              let height = record["height"] as? CGFloat
        else {
            print("we did not set the orbit correctly")
            return nil
        }

        self.init(name: name, width: width, height: height)
    }
}
