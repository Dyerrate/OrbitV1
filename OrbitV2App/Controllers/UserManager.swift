//
//  UserManager.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/5/23.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    let testUser = User(email: "Test@gmail.com", password: "Test123", firstName: "Sam", lastName: "Dyer", phoneNumber: "3253477320")
    var users: [User] = []

     init() {
         fetchUsers()
         users.append(testUser)
          
     }

    func registerUser(user: User, completion: ((Bool, Error?) -> Void)? = nil) {
        // Your registration logic here, e.g., saving the user to a database, making API calls, etc.
        // ...
        users.append(user)
         let userDataArray = users.map { $0.dictionaryRepresentation }
         UserDefaults.standard.set(userDataArray, forKey: "userData")
        // For now, let's simulate a successful registration by waiting for 2 seconds
        // and then returning a tuple (success: Bool, error: Error?)
        // Replace this mock implementation with your actual registration logic
        Thread.sleep(forTimeInterval: 2.0)
        
        // Check if the email is already registered
        if user.email == "alreadyRegistered@example.com" {
            let error = NSError(domain: "UserManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Email already registered."])
            completion?(false, error)
            return
        }
        
        // If everything is fine, return success as true and error as nil
        completion?(true, nil)
    }

    func authenticateUser(email: String, password: String, completion: (Result<User, Error>) -> Void) {
        if let user = users.first(where: { $0.email == email && $0.password == password }) {
            completion(.success(user))
        } else {
            completion(.failure(NSError(domain: "UserManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid email or password"])))
        }
    }
    
    func fetchUsers() {
        if let savedUsers = UserDefaults.standard.array(forKey: "userData") as? [[String: Any]] {
            users = savedUsers.compactMap { User(dictionary: $0) }
        }
    }
}
