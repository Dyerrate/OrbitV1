//
//  PlanetManager.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 6/22/23.
//

import Foundation
import CloudKit

class PlanetManager {
    
    // Properties to store the logged-in user and the planet list array
    private var loggedInUser: User
    private var planetList: [Planet]
    
    // Initializer that accepts the logged-in user and planet list array
    init(loggedInUser: User, planetList: [Planet]) {
        self.loggedInUser = loggedInUser
        self.planetList = planetList
    }
    
    // Methods for making calls to the database and managing the user's data
    // ...
    
    
}
