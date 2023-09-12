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

            operation.recordMatchedBlock = { (recordID, result) in
                switch result {
                case .success(let record):
                    fetchedRecord = record
                case .failure(let error):
                    print(error)
                    }
            }
            operation.queryResultBlock = { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        completion(fetchedRecord)
                        // ...
                    case .failure(let error):
                        print(error)
                        completion(nil)
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

    func getNotifications(for planet: Planet, completionHandler: @escaping (Planet, [Notification]) -> Void) {
        let notificationReferences = planet.notifications
        let recordIDs = notificationReferences.map { $0.recordID }
        
        let fetchOperation = CKFetchRecordsOperation(recordIDs: recordIDs)
        fetchOperation.desiredKeys = ["date", "description", "title", "notificationType", "imageName", "priority", "actionTaken"]
        var notifications: [Notification] = []
        fetchOperation.perRecordCompletionBlock = { record, _, error in
            if let record = record {
                let notification = Notification(record: record)
                notifications.append(notification)
            } else if let error = error {
                print("Error fetching notification record: \(error.localizedDescription)")
            }
        }
        
        fetchOperation.fetchRecordsCompletionBlock = { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")
                } else {
                    completionHandler(planet, notifications)
                }
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(fetchOperation)
    }
    func setSolarSystem(for user: User, completionHandler: @escaping ([Planet: [Notification]]) -> Void) {
        setPlanets(for: user) { planets in
            var solarSystem: [Planet: [Notification]] = [:]
            let group = DispatchGroup()

            for planet in planets {
                group.enter()
                self.getNotifications(for: planet) { planetWithNotifications, notifications in
                    solarSystem[planetWithNotifications] = notifications
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                print("Solar system with notifications: ", solarSystem)
                completionHandler(solarSystem)
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

        fetchOperation.perRecordCompletionBlock   = { record, _, error in
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

                let sortedRecords = fetchedRecords.sorted { (record1, record2) -> Bool in
                    let position1 = record1["position"] as? Int ?? 0
                    let position2 = record2["position"] as? Int ?? 0
                    return position1 < position2
                }

                let fetchGroup = DispatchGroup()

                for record in sortedRecords {
                    if let planet = Planet(record: record) {
                        DispatchQueue.main.async {
                            print("appended planet notification: ", planet.notifications)
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
    
    func removePlanetNotificationList(user: User, planet: Planet, notifications: [Notification], completion: @escaping (Result<Void, Error>) -> Void) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let planetReferences = user.planets
        let recordIDs = planetReferences.map { $0.recordID }
        let fetchOperation = CKFetchRecordsOperation(recordIDs: recordIDs)
        print("We are deleting a record here: UserManager.removePlanetNotificationList")
        // Step 1: Fetch planet records and remove the specified notifications
        fetchOperation.perRecordCompletionBlock = { record, recordID, error in
            if let error = error {
                print("Error fetching planet record: \(error.localizedDescription)")
            } else if let record = record, record["name"] as? String == planet.name {
                var existingNotificationReferences = record["notifications"] as? [CKRecord.Reference] ?? []
                existingNotificationReferences = existingNotificationReferences.filter { reference in
                    !notifications.contains(where: { $0.recordID == reference.recordID })
                }
                record["notifications"] = existingNotificationReferences as CKRecordValue
                publicDatabase.save(record) { (record, error) in
                    if let error = error {
                        print("Error saving planet record when deleting: \(error.localizedDescription)")
                    } else {
                        print("Successfully saved planet record with removed notifications.")
                        completion(.success(()))
                    }
                }
            }
        }

        fetchOperation.fetchRecordsCompletionBlock = { records, error in
            if let error = error {
                print("Error fetching records for deletion completion: \(error.localizedDescription)")
            } else if let records = records {
                print("Fetched records from deletion: ", records)
            }
        }
        publicDatabase.add(fetchOperation)
    }
    
    func updateNotificationPriority(notifications: [Notification], completion: @escaping (Result<Void, Error>) -> Void) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let dispatchGroup = DispatchGroup()
        
        for notification in notifications {
            dispatchGroup.enter()
            print("this is what we are passing in to the record reader for priority: ", [notification.recordID!])
            let fetchOperation = CKFetchRecordsOperation(recordIDs: [notification.recordID!])
            // Fetch the notification record
            fetchOperation.perRecordCompletionBlock = { record, _, error in
                if let error = error {
                    print("Error fetching notification record: \(error.localizedDescription)")
                } else if let record = record {
                    // Update the 'priority' field of the record
                    record["priority"] = notification.priority
                    // Save the updated record back to the database
                    publicDatabase.save(record) { (savedRecord, saveError) in
                        if let saveError = saveError {
                            print("Error saving notification record: \(saveError.localizedDescription)")
                        } else {
                            print("Successfully updated notification record priority.")
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            publicDatabase.add(fetchOperation)
        }
        dispatchGroup.notify(queue: .main) {
            print("Successfully updated all notification priorities.")
            completion(.success(()))
        }
    }

    func addPlanetNotificationList(user: User, planet: Planet, notifications: [Notification], completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        var notificationRecords = [CKRecord]()
        var newNotificationsToReturn = [CKRecord]()
        let planetReferences = user.planets
        let recordIDs = planetReferences.map { $0.recordID }
        let fetchOperation = CKFetchRecordsOperation(recordIDs: recordIDs)
        var fetchedRecords = [CKRecord]()
        print("recordIDs from UPDATE: ", recordIDs)

        // Step 1: Convert Notification objects to CKRecord objects and save them to the database
        let dispatchGroup = DispatchGroup()
        for notification in notifications {
            let notificationRecord = createNotificationRecord(notification: notification)
            notificationRecords.append(notificationRecord)
            dispatchGroup.enter()
            publicDatabase.save(notificationRecord) { (record, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error saving notification record: \(error.localizedDescription)")
                        dispatchGroup.leave()
                    } else {
                        print("Successfully saved notification record.")
                        dispatchGroup.leave()
                    }
                }
            }
        }
        // Wait for all saving operations to finish before proceeding
        dispatchGroup.notify(queue: .main) {
            fetchOperation.perRecordCompletionBlock = { record, _, error in
                if let error = error {
                    print("Error fetching planet record for planet: \(error.localizedDescription)")
                } else if let record = record, record["name"] as? String == planet.name {
                    fetchedRecords.append(record)
                    let existingNotificationReferences = record["notifications"] as? [CKRecord.Reference] ?? []
                    newNotificationsToReturn = notificationRecords
                    let newNotificationReferences = notificationRecords.map { CKRecord.Reference(record: $0, action: .none) }
                    let updatedNotificationReferences = existingNotificationReferences + newNotificationReferences
                    record["notifications"] = updatedNotificationReferences as CKRecordValue
                    publicDatabase.save(record) { (savedRecord, saveError) in
                        if let saveError = saveError {
                            print("Error saving planet record in add: \(saveError.localizedDescription)")
                        } else {
                            print("Successfully saved planet record with new notifications.")
                            
                        }
                    }
                }
            }
            fetchOperation.fetchRecordsCompletionBlock = { records, error in
                if let error = error {
                    print("Error fetching records: \(error.localizedDescription)")
                    completion(.failure(error))
                    
                } else {
                    print("Fetched records: ", records!)
                    completion(.success(newNotificationsToReturn))
                }
            }
            publicDatabase.add(fetchOperation)
        }
    }

    func createNotificationRecord(notification: Notification) -> CKRecord {
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let notificationRecord = CKRecord(recordType: "Notification", recordID: recordID)
        notificationRecord["notificationType"] = notification.type
        notificationRecord["description"] = notification.description
        notificationRecord["priority"] = notification.priority
        notificationRecord["title"] = notification.title
        print("UPDATE: new notification record: ", notificationRecord)
        return notificationRecord
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

