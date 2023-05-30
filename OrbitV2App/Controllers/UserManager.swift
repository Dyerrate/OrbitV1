//
//  UserManager.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/5/23.
//

import Foundation
import CloudKit

class UserManager {
    static let shared = UserManager()
    var users: [User] = []

    init() {

    }

    func createUser(user: User, planets: [CKRecord.Reference], completion: @escaping (Result<CKRecord, Error>) -> Void) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let userRecord = CKRecord(recordType: "User")


        userRecord["email"] = user.email
        userRecord["fullName"] = user.fullName
        userRecord["uuid"] = user.uuid
        userRecord["planets"] = planets // <-- new

        publicDatabase.save(userRecord) { (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let record = record {
                    completion(.success(record))
                }
            }
        }
    }

    func fetchUsers() {
        if let savedUsers = UserDefaults.standard.array(forKey: "userData") as? [[String: Any]] {
            users = savedUsers.compactMap { User(dictionary: $0) }
        }
    }
    func updateUserName(uuid: String, fullName: String, currentUser: User, completion: @escaping (Result<User, Error>) -> Void) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase

        fetchUserRecord(uuid: uuid) { userRecord in
            guard let userRecord = userRecord else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: 1002, userInfo: [NSLocalizedDescriptionKey: "User does not exist"])))
                }
                return
            }

            userRecord["fullName"] = fullName

            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [userRecord], recordIDsToDelete: nil)
            modifyOperation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    var updatedUser = currentUser
                    updatedUser.fullName = fullName
                    DispatchQueue.main.async {
                        completion(.success(updatedUser))
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
            publicDatabase.add(modifyOperation)
        }
    }
    func fetchUserRecord(uuid: String?, completion: @escaping (CKRecord?) -> Void) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase

        if let uuid = uuid {
            let predicate = NSPredicate(format: "uuid == %@", uuid)
            let query = CKQuery(recordType: "User", predicate: predicate)

            let operation = CKQueryOperation(query: query)
            operation.resultsLimit = 1

            var fetchedRecord: CKRecord?

            operation.recordFetchedBlock = { record in
                fetchedRecord = record
            }

            operation.queryCompletionBlock = { cursor, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error)
                        completion(nil)
                    } else {
                        completion(fetchedRecord)
                    }
                }
            }

            publicDatabase.add(operation)
        } else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    func createDefaultData(for user: User, completion: @escaping (Result<[CKRecord.Reference], Error>) -> Void) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase

        let recordNames = ["D097A36B-CF50-8338-0A6F-AD6689AC2B48",
                           "F44E4D69-9BB2-BD6C-212D-C634527DF2B0",
                           "FF8151FC-B9F6-F821-B215-FE5BFEA61F96"]

        let recordIDs = recordNames.map { CKRecord.ID(recordName: $0) }

        publicDatabase.fetch(withRecordIDs: recordIDs) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recordsByID):
                    let planetReferences = recordsByID.values.compactMap { recordResult -> CKRecord.Reference? in
                        switch recordResult {
                        case .success(let record):
                            return CKRecord.Reference(record: record, action: .none)
                        case .failure(let error):
                            print("Error fetching planet: \(error)")
                            return nil
                        }
                    }
                    completion(.success(planetReferences))
                case .failure(let error):
                    print("Error fetching default planets: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func setUser(uuid: String, completion: @escaping (Result<User, Error>) -> Void) {
        getUser(by: uuid, fullName: nil, email: nil) { (result) in
            switch result {
            case .success(let user):
                // Check if user's fullName is empty
                if let user = user, user.fullName.isEmpty {
                    // Handle the UI part in SolarSystemViewController
                    //completion(.failure(NSError(domain: "", code: 1001, userInfo: [NSLocalizedDescriptionKey: "User's fullName is empty"])))
                    completion(.success(user ))
                } else {
                    completion(.success(user ?? User(email: "", fullName: "", uuid: "", planets: [])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func setSolarSystem(for user: User, completionHandler: @escaping ([Planet: Orbit]) -> Void) {
            setPlanets(for: user) { planets in
                var solarSystem: [Planet: Orbit] = [:]
                
                for planet in planets {
                    self.setOrbit(for: planet) { orbit in
                        solarSystem[planet] = orbit
                        
                        // Check if all planets have been processed
                        if solarSystem.count == planets.count {
                            print("Lets see the complete solarSystem: ", solarSystem)
                            completionHandler(solarSystem)
                        }
                    }
                }
            }
        }

    func setPlanets(for user: User, completion: @escaping ([Planet]) -> Void) {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase

        let planetReferences = user.planets
        let recordIDs = planetReferences.map { $0.recordID }

        let fetchOperation = CKFetchRecordsOperation(recordIDs: recordIDs)
        var fetchedRecords = [CKRecord]()
        print("recordIDs: ", recordIDs)

        fetchOperation.perRecordCompletionBlock = { record, _, error in
            if let error = error {
                print("Error fetching planet record: \(error.localizedDescription)")
            } else if let record = record {
                fetchedRecords.append(record)
            }
        }

        fetchOperation.fetchRecordsCompletionBlock = { _, error in
            if let error = error {
                print("Error fetching planet records: \(error.localizedDescription)")
                completion([])
            } else {
                var planets = [Planet]()

                let fetchGroup = DispatchGroup()

                for record in fetchedRecords {
                    if let planet = Planet(record: record) {
                        DispatchQueue.main.async {
                            print("appended planet: ", planet)
                            planets.append(planet)
                        }
                    }
                }

                fetchGroup.notify(queue: .main) {
                    completion(planets)
                }
            }
        }

        database.add(fetchOperation)
    }
    
    func setOrbit(for planet: Planet, completionHandler: @escaping (Orbit?) -> Void) {
        let recordID = planet.orbitReference.recordID
        let fetchOperation = CKFetchRecordsOperation(recordIDs: [recordID])

        fetchOperation.perRecordCompletionBlock = { record, _, error in
            if let error = error {
                print("Error fetching Orbit record: \(error.localizedDescription)")
                completionHandler(nil)
            } else if let record = record {
                let orbit = Orbit(record: record) // Assuming you have an Orbit initializer that takes a CKRecord
                print("lets see the record: ", record)
                print("now lets see the orbit", orbit!)
                completionHandler(orbit)
            } else {
                print("The orbit has failed to be set...")
                completionHandler(nil)
            }
        }

        CKContainer.default().publicCloudDatabase.add(fetchOperation)
    }
 
    
    
    func getUser(by uuid: String, fullName: String?, email: String?, completion: @escaping (Result<User?, Error>) -> Void) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        let query = CKQuery(recordType: "User", predicate: predicate)

        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1
        operation.desiredKeys = ["email", "fullName", "uuid", "planets"] // <-- new

        var fetchedUser: User?
        var recordFetched = false

        operation.recordMatchedBlock = { (recordID, result) in
            switch result {
            case .success(let record):
                let email = record["email"] as? String
                let fullName = record["fullName"] as? String
                let uuid = record["uuid"] as? String
                let planets = record["planets"] as? [CKRecord.Reference] // <-- new
                fetchedUser = User(email: email ?? "", fullName: fullName ?? "", uuid: uuid ?? "", planets: planets ?? []) // <-- new
                recordFetched = true
                print("Record fetched successfully: \(String(describing: fetchedUser))")
            case .failure(let error):
                print("Failed to fetch user record: \(error)")
            }
        }

        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if recordFetched {
                        completion(.success(fetchedUser))
                        print("User fetched successfully.")
                    } else {
                        // No user record exists, create a new one
                        print("No user fetched, creating a new user.")
                        self.createDefaultData(for: User(email: email ?? "", fullName: fullName ?? "", uuid: uuid, planets: [])) { result in
                            switch result {
                            case .success(let planets):
                                let newUser = User(email: email ?? "", fullName: fullName ?? "", uuid: uuid, planets: planets)
                                self.createUser(user: newUser, planets: planets) { result in
                                    switch result {
                                    case .success(let record):
                                        print("User created successfully: \(record)")
                                        let email = record["email"] as? String
                                        let fullName = record["fullName"] as? String
                                        let uuid = record["uuid"] as? String
                                        let planets = record["planets"] as? [CKRecord.Reference]
                                        completion(.success(User(email: email ?? "", fullName: fullName ?? "", uuid: uuid ?? "", planets: planets ?? [])))
                                    case .failure(let error):
                                        print("Failed to create user: \(error)")
                                        completion(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                print("Failed to fetch default planets: \(error)")
                                completion(.failure(error))
                            }
                        }
                    }
                case .failure(let error):
                    print("Query result error: \(error)")
                    completion(.failure(error))
                }
            }
        }

        publicDatabase.add(operation)
    }
}

