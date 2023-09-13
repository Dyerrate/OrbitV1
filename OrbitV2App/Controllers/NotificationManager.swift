//
//  NotificationManager.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 4/1/23.
//
import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    // Add a method to check for notification access
    var throttle: Int = 10
    let queue = DispatchQueue(label: "com.OrbitV2App.NotificationManager")
    
    func requestAccess(completion: @escaping (UNAuthorizationStatus) -> Void) {
        // Check for notification access and call the completion handler with the status
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("ERROR: \(error)")
                completion(.denied)
            } else {
                print("SUCCESS")
                completion(.authorized)
            }
        }
    }
    //TESTING: To remove after we are done testing
    func deleteAll(dispatchForFinished: DispatchGroup) {
        print("We are trying to delete all notifications")
        grabNotificationPushers() {(request) in
            self.removeNotificationPushArray(notificationArray: request)
            dispatchForFinished.leave()
        }
    }
    
    func deleteAllType(dispatchForFinished: DispatchGroup, weightType: String) {
        print("We are deleting this category type to make new")
        grabNotificationPushers() {(request) in
            self.removeIndividaulNotification(notificationArray: request, categoryType: weightType)
            dispatchForFinished.leave()
        }
    }

    func checkAccess(completion: @escaping (UNAuthorizationStatus) -> Void) {
        // Check for notification access and call the completion handler with the status
        print("Checking notification access status....")
        let _: Void = UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                print("Authorized")
            case .denied:
                print("Denied")
            case .notDetermined:
                print("Not Determined")
            case .provisional:
                print("Provisional")
            case .ephemeral:
                print("Ephemeral")
            @unknown default:
                print("Unknown")
            }
            completion(settings.authorizationStatus)
        })
    }
    
    private func grabDeliveredNotificationsThisMonth(completion: @escaping ([UNNotification]) -> Void) {
        print("We are grabbing the notifications that have been delivered")
        let connection = UNUserNotificationCenter.current()
        connection.getDeliveredNotifications { (delivered: [UNNotification]) in
            let calendar = Calendar.current
            let now = Date()
            let currentYear = calendar.component(.year, from: now)
            let currentMonth = calendar.component(.month, from: now)
            let filteredNotifications = delivered.filter { notification in
                let notificationDate = notification.date
                let notificationYear = calendar.component(.year, from: notificationDate)
                let notificationMonth = calendar.component(.month, from: notificationDate)
                
                return notificationYear == currentYear && notificationMonth == currentMonth
            }
            completion(filteredNotifications)
        }
    }
    
    
    
    func updateFromSolarSystem(planetList: [Planet: [Notification]], planetOrbit: Int) {
        print("Start: updateFromSolarSystem ")
        queue.async {
            print("Step: Into nManager updateFromSolarSystem")
            let dispatchForUpdate = DispatchGroup()
            var amountDelivered: Int = 0
            var pendingNotifications: [UNNotificationRequest] = []
            dispatchForUpdate.enter()
            self.grabDeliveredNotificationsThisMonth() {(delivered) in
                print("Here are the delivered notifications: \(delivered.count)")
                amountDelivered = delivered.count
                dispatchForUpdate.leave()
            }
            
            dispatchForUpdate.enter()
            self.grabNotificationPushers() {(request) in
                print("We are grabbing the notififications for the updateFromSolar")
                pendingNotifications = request
                dispatchForUpdate.leave()
            }
            
            dispatchForUpdate.notify(queue: .main) {
                var amountLeftToPush: Int = self.throttle - amountDelivered
                let dispatchForDelete = DispatchGroup()
                if(amountDelivered >= self.throttle) {
                    print("We shouldn't add anymore for this month and wait for next.....")
                } else {
                    for (planet, _) in planetList{
                        if planet.position == planetOrbit {
                            print("planetOrbit at start switch: \(planetOrbit)")
                            switch planetOrbit {
                                //figure out how we can either update transfromForPusher method or create a new one for the updates.
                                //As to when or how we can compare is still unkown as we want the titles to be custom
                            case 1:
                                self.setNotificationsOrbit(planetPositon: planetOrbit, planetList: planetList, currentPlanet: planet, roomToPush: amountLeftToPush) {(notificationFromMethod, weight) in
                                    var rawNotifications: (notificationList: [Notification], notificationWeight: String) = ([], "")
                                    var organizedNotifications = [rawNotifications]
                                    var grabbedNotifications: [Notification] = []
                                    organizedNotifications = []
                                    grabbedNotifications = notificationFromMethod
                                    var intialCount: Int = grabbedNotifications.count
                                    
                                    for pending in pendingNotifications {
                                        for not in notificationFromMethod {
                                            if(not.recordID?.recordName == pending.identifier) {
                                                print("We are removing the pending notification as it already exists")
                                                grabbedNotifications.removeAll(where: {$0.recordID?.recordName == pending.identifier})
                                            }
                                        }
                                    }
                                    dispatchForDelete.enter()
                                    if(intialCount == grabbedNotifications.count) {
                                        self.deleteAllType(dispatchForFinished: dispatchForDelete, weightType: "small")
                                    } else {
                                        dispatchForDelete.leave()
                                    }
                                    dispatchForDelete.notify(queue: .main) {
                                        rawNotifications.notificationList = grabbedNotifications
                                        rawNotifications.notificationWeight = weight
                                        organizedNotifications.append(rawNotifications)
                                        print("What we are sending to the transformer organizedNotifications small: \(organizedNotifications)")
                                        self.transformNotificationsForPush(organizedNotifications)
                                    }
                                }
                            case 2:
                                self.setNotificationsOrbit(planetPositon: planetOrbit, planetList: planetList, currentPlanet: planet, roomToPush: amountLeftToPush) {(notificationFromMethod, weight) in
                                    var rawNotifications: (notificationList: [Notification], notificationWeight: String) = ([], "")
                                    var organizedNotifications = [rawNotifications]
                                    organizedNotifications = []
                                    var grabbedNotifications: [Notification] = []
                                    grabbedNotifications = notificationFromMethod
                                    var intialCount: Int = grabbedNotifications.count

                                    for pending in pendingNotifications {
                                        for not in notificationFromMethod {
                                            if(not.recordID?.recordName == pending.identifier) {
                                                print("We are removing the pending notification as it already exists")
                                                grabbedNotifications.removeAll(where: {$0.recordID?.recordName == pending.identifier})
                                            }
                                        }
                                    }
                                    dispatchForDelete.enter()
                                    if(intialCount == grabbedNotifications.count) {
                                        self.deleteAllType(dispatchForFinished: dispatchForDelete, weightType: "medium")
                                    } else {
                                        dispatchForDelete.leave()
                                    }
                                    dispatchForDelete.notify(queue: .main) {
                                        rawNotifications.notificationList = grabbedNotifications
                                        rawNotifications.notificationWeight = weight
                                        organizedNotifications.append(rawNotifications)
                                        print("What we are sending to the transformer organizedNotifications medium: \(organizedNotifications)")
                                        self.transformNotificationsForPush(organizedNotifications)
                                    }
                                }
                            case 3:
                                self.setNotificationsOrbit(planetPositon: planetOrbit, planetList: planetList, currentPlanet: planet, roomToPush: amountLeftToPush) {(notificationFromMethod, weight) in
                                    var rawNotifications: (notificationList: [Notification], notificationWeight: String) = ([], "")
                                    var organizedNotifications = [rawNotifications]
                                    var grabbedNotifications: [Notification] = []
                                    organizedNotifications = []
                                    grabbedNotifications = notificationFromMethod
                                    var intialCount: Int = grabbedNotifications.count
                                    
                                    for pending in pendingNotifications {
                                        for not in notificationFromMethod {
                                            if(not.recordID?.recordName == pending.identifier) {
                                                print("We are removing the pending notification as it already exists")
                                                grabbedNotifications.removeAll(where: {$0.recordID?.recordName == pending.identifier})
                                            }
                                        }
                                    }
                                    dispatchForDelete.enter()
                                    if(intialCount == grabbedNotifications.count) {
                                        self.deleteAllType(dispatchForFinished: dispatchForDelete, weightType: "high")
                                    } else {
                                        dispatchForDelete.leave()
                                    }
                                    dispatchForDelete.notify(queue: .main) {
                                        rawNotifications.notificationList = grabbedNotifications
                                        rawNotifications.notificationWeight = weight
                                        organizedNotifications.append(rawNotifications)
                                        print("What we are sending to the transformer organizedNotifications high: \(organizedNotifications)")
                                        self.transformNotificationsForPush(organizedNotifications)
                                    }
                                }
                            default:
                                continue
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    //This runs at the loading start of new app load
    func onStartConfig(planetList: [Planet: [Notification]]) {
        var currentlyPushed: Int = 0
        //setting the days left in this month
        grabNotificationPushers() {(request) in
            currentlyPushed = request.count
            print("Here are the pushed initally: \(currentlyPushed)")
            if request.isEmpty{
                self.setNotificationPusher(planetList: planetList, passedRequestAmount: request.count)
            } else if(request.count > self.throttle) {
                print("Here is the func when we have a higher count than throttle")
                self.removeNotificationPushArray(notificationArray: request)
                self.setNotificationPusher(planetList: planetList, passedRequestAmount: request.count)
            }
            //TODO: run a configuration check to see how many we have que'd up for this user. Making sure it doesn't exceed
        }
        print("Completed the notification config ")
    }
    
    //Grabes all the pending Notification Requests
    private func grabNotificationPushers(completion: @escaping ([UNNotificationRequest]) -> Void) {
        print("We are grabbing the notifications that have been pushed")
        let connection = UNUserNotificationCenter.current()
        connection.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            completion(requests)
        }
    }
    
    func getCurrentDate() -> (day: Int, month: Int, year: Int, totalDaysInMonth: Int, daysLeftInMonth: Int) {
            let date = Date()
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            // Get the range of days for the current month
            guard let range = calendar.range(of: .day, in: .month, for: date) else {
                return (day, month, year, 0, 0)
            }
            // Calculate the number of days in the month
            let totalDaysInMonth = range.count
            // Calculate the number of days left in the month
            let daysLeftInMonth = totalDaysInMonth - day
            print("We grabbed the date")
            return (day, month, year, totalDaysInMonth, daysLeftInMonth)
        }
    
    func setNotificationPusher(planetList: [Planet: [Notification]], passedRequestAmount: Int) {
        //create the tuple
        var rawNotifications: (notificationList: [Notification], notificationWeight: String) = ([], "")
        let dispatchForStart = DispatchGroup()
        var amountDelivered: Int = 0
        dispatchForStart.enter()
        self.grabDeliveredNotificationsThisMonth() {(delivered) in
            print("Here are the delivered notifications: \(delivered.count)")
            amountDelivered = delivered.count
            dispatchForStart.leave()
        }
        
        //set the array to hold the tuples
        //NOTE: This does keep a empty rawNotifications array there.
        var organizedNotifications = [rawNotifications]
        //loop through each planet
        dispatchForStart.notify(queue: .main){
            let amountLeft = self.throttle - amountDelivered
            for (planet, _) in planetList {
                let planetPositions = planet.position
                self.setNotificationsOrbit(planetPositon: planetPositions!, planetList: planetList, currentPlanet: planet, roomToPush: amountLeft) {(orbitTuple) in
                    rawNotifications.notificationList = orbitTuple.0
                    rawNotifications.notificationWeight = orbitTuple.1
                    organizedNotifications.append(rawNotifications)
                }
            }
            self.transformNotificationsForPush(organizedNotifications)
        }
    }
    
    func transformNotificationsForPush(_ organizedNotifications: [(notificationList: [Notification], notificationWeight: String)]){
        print("Starting transformNotificationforPush")
        var transformedNotifications: [(UNMutableNotificationContent, String)] = []
        let currentDateInfo = getCurrentDate()
        for tuple in organizedNotifications {
            transformedNotifications = []
            let notificationList = tuple.notificationList
            let notificationWeight = tuple.notificationWeight
            switch notificationWeight {
            case "small", "medium", "high":
                for notification in notificationList {
                    let category = NotificationCategory(rawValue: notification.type)!
                    let content = UNMutableNotificationContent()
                    content.title = category.titles.randomElement() ?? notification.title
                    content.categoryIdentifier = notificationWeight
                    if(notification.type == "contact"){
                        content.body = category.bodies.randomElement() ?? notification.description!
                    } else {
                        content.body = notification.description!
                    }
                    content.sound = .default
                    print("We are pushing this notifications content: \(content)")
                    transformedNotifications.append((content, notification.recordID?.recordName ?? "No Record ID"))
                }
                smallNotificationPusher(notificationList: transformedNotifications, currentDateInfo: currentDateInfo)
            default:
                break
            }
        }
    }
    
    private func smallNotificationPusher(notificationList: [(UNMutableNotificationContent, String)], currentDateInfo: (day: Int, month: Int, year: Int, totalDaysInMonth: Int, daysLeftInMonth: Int)) {
        var dayCounterCheck = currentDateInfo.day
        var NotificationsArrayToPush: [UNNotificationRequest] = []
        var currentMonth = currentDateInfo.month
        var currentYear = currentDateInfo.year
        for (content, recordId) in notificationList {
            let randomShortDate = Int.random(in: 1...5)
            let randomHour = Int.random(in: 8...20)
            var dateComponents = DateComponents()
            let sendDate = randomShortDate + dayCounterCheck
            
            //Check sendDate is less than days in the month first
            if(sendDate <= currentDateInfo.totalDaysInMonth ) {
                dateComponents.day = sendDate
                dateComponents.month = currentMonth
                dateComponents.year = currentDateInfo.year
                dateComponents.hour = randomHour
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                //createNotificationPush()
                let notificationToPush = UNNotificationRequest(identifier: recordId, content: content, trigger: trigger)
                NotificationsArrayToPush.append(notificationToPush)
                dayCounterCheck += 5
                
            } else if(sendDate > currentDateInfo.totalDaysInMonth ){
                currentMonth += 1
                if (currentMonth > 12) {
                    currentMonth = 1
                    currentYear += 1
                }
                let newDate = sendDate - currentDateInfo.totalDaysInMonth
                dateComponents.day = newDate
                dateComponents.month = currentMonth
                dateComponents.year = currentYear
                dateComponents.hour = randomHour
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents as DateComponents, repeats: false)
                //createNotificationPush()
                let notificationToPush = UNNotificationRequest(identifier: recordId, content: content, trigger: trigger)
                NotificationsArrayToPush.append(notificationToPush)
                dayCounterCheck += 5
            }
        }
        print("Small pusher is sending: \(NotificationsArrayToPush)")
        self.createNotificationPush(toBePushed: NotificationsArrayToPush)
    }
    
    private func mediumNotificationPusher(notificationList: [(UNMutableNotificationContent, String)], currentDateInfo: (day: Int, month: Int, year: Int, totalDaysInMonth: Int, daysLeftInMonth: Int)) {
        var dayCounterCheck = currentDateInfo.day
        var NotificationsArrayToPush: [UNNotificationRequest] = []
        var currentMonth = currentDateInfo.month
        var currentYear = currentDateInfo.year
        
        for (content, recordId) in notificationList {
            let randomWeekDay = Int.random(in: 1...14)
            let randomHour = Int.random(in: 8...20)
            var dateComponents = DateComponents()
            let sendDate = randomWeekDay + dayCounterCheck
            
            if(sendDate <= currentDateInfo.totalDaysInMonth ) {
                
                dateComponents.day = sendDate
                dateComponents.month = currentMonth
                dateComponents.year = currentDateInfo.year
                dateComponents.hour = randomHour
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                //createNotificationPush()
                let notificationToPush = UNNotificationRequest(identifier: recordId, content: content, trigger: trigger)
                NotificationsArrayToPush.append(notificationToPush)
                dayCounterCheck += 14
                
            } else if(sendDate > currentDateInfo.totalDaysInMonth ){
                currentMonth += 1
                if (currentMonth > 12) {
                    currentMonth = 1
                    currentYear += 1
                }
                let newDate = sendDate - currentDateInfo.totalDaysInMonth
                dateComponents.day = newDate
                dateComponents.month = currentMonth
                dateComponents.year = currentYear
                dateComponents.hour = randomHour
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents as DateComponents, repeats: false)
                //createNotificationPush()
                let notificationToPush = UNNotificationRequest(identifier: recordId, content: content, trigger: trigger)
                NotificationsArrayToPush.append(notificationToPush)
                dayCounterCheck += 14
            }
        }
        print("Medium pusher is sending: \(NotificationsArrayToPush)")
        self.createNotificationPush(toBePushed: NotificationsArrayToPush)
    }
    
    private func highNotificationPusher(notificationList: [(UNMutableNotificationContent, String)], currentDateInfo: (day: Int, month: Int, year: Int, totalDaysInMonth: Int, daysLeftInMonth: Int)) {
        var NotificationsArrayToPush: [UNNotificationRequest] = []
        var currentMonth = currentDateInfo.month
        var currentYear = currentDateInfo.year
        for (content, recordId) in notificationList {
            let randomDayOfMonth = Int.random(in: 1...currentDateInfo.totalDaysInMonth)
            let randomHour = Int.random(in: 8...20)
            var dateComponents = DateComponents()
            if currentMonth > 12 {
                currentMonth = 1
                currentYear += 1
            }
            dateComponents.day = randomDayOfMonth
            dateComponents.month = currentMonth
            dateComponents.year = currentYear
            dateComponents.hour = randomHour
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                //createNotificationPush()
            let notificationToPush = UNNotificationRequest(identifier: recordId, content: content, trigger: trigger)
            NotificationsArrayToPush.append(notificationToPush)
        }
        print("High pusher is sending: \(NotificationsArrayToPush)")
        self.createNotificationPush(toBePushed: NotificationsArrayToPush)
    }
    
    private func createNotificationPush(toBePushed: [UNNotificationRequest]) {
        let connection = UNUserNotificationCenter.current()
        for notification in toBePushed {
            connection.add(notification) { (error: Error?) in
                if let error = error {
                    print("Error: \(error.localizedDescription) for the notification: \(notification.content.title)")
                }
            }
            print("We successfully pushed this notification: \(notification)")
        }
    }
    
    //To remove all notification
    private func removeNotificationPushArray(notificationArray: [UNNotificationRequest]) {
        let connection = UNUserNotificationCenter.current()
        let identifiers = notificationArray.map { $0.identifier }
        connection.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("The removeNotificationPushArray ran and executed: \(identifiers)")
    }
    
    //Remove single notification
    func removeIndividaulNotification(notificationArray: [UNNotificationRequest], categoryType: String){
        let connection = UNUserNotificationCenter.current()
        let identifiers = notificationArray
                .filter { $0.content.categoryIdentifier == categoryType }
                .map { $0.identifier }
        connection.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("The removeIndividaulNotification ran and executed: \(identifiers)")
    }
    
    func addIndividualNotification(notification: UNNotificationRequest) {
        
    }
    
    
    //Testing to make sure the notifications system works
//    func testThisOut() {
//        let connection = UNUserNotificationCenter.current()
//        let content = UNMutableNotificationContent()
//
//        content.title = "Orbit Reminder"
//        content.body = "Reach out to Steve this week!"
//        content.sound = UNNotificationSound.default
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
//        let pushing = UNNotificationRequest(identifier: "test1", content: content, trigger: trigger)
//
//        connection.add(pushing) { (error: Error?) in
//            if let error = error {
//                print("Error: \(error.localizedDescription) for the notification: \(pushing.content.title)")
//            }
//        }
//    }
    
    //Sets the notifications based on the Orbit for each planets
    private func setNotificationsOrbit(planetPositon: Int, planetList: [Planet: [Notification]], currentPlanet: Planet, roomToPush: Int, completion: @escaping (([Notification],String)) -> Void ) {
        print("We are setting notifications to orbit now....")
        var toRetunNotifications: [Notification] = []
        var weightReturn: String = ""
        //INFO: We are grabbing based on the planets position and adding the weight to return in a tuple for us to use to sort out the notifications info that will be pushed.
        switch planetPositon {
        case 1:
            weightReturn = "small"
            if var planetNotifications = planetList[currentPlanet] {
                planetNotifications.sort{$0.priority < $1.priority}
                for notification in planetNotifications {
                    if (toRetunNotifications.count == 5 || toRetunNotifications.count == planetNotifications.count || toRetunNotifications.count == roomToPush) {
                        completion((toRetunNotifications,weightReturn))
                    } else {
                        if(notification.actionTaken! < 2) {
                            toRetunNotifications.append(notification)
                        } else {
                            //Where we can handle a new notification to be send to recommend changing their priority
                            continue
                        }
                    }
                }
                if(toRetunNotifications.count == planetNotifications.count) {
                    completion((toRetunNotifications,weightReturn))
                }
            }
        case 2:
            weightReturn = "medium"
            if var planetNotifications = planetList[currentPlanet] {
                planetNotifications.sort{$0.priority < $1.priority}
                for notification in planetNotifications {
                    if (toRetunNotifications.count == 5 || toRetunNotifications.count == planetNotifications.count || toRetunNotifications.count == roomToPush) {
                        completion((toRetunNotifications,weightReturn))
                    } else {
                        if(notification.actionTaken! < 2) {
                            toRetunNotifications.append(notification)
                        } else {
                            //Where we can handle a new notification to be send to recommend changing their priority
                            continue
                        }
                    }
                }
                if(toRetunNotifications.count == planetNotifications.count) {
                    completion((toRetunNotifications,weightReturn))
                }
            }
        case 3:
            weightReturn = "high"
            if var planetNotifications = planetList[currentPlanet] {
                planetNotifications.sort{$0.priority < $1.priority}
                for notification in planetNotifications {
                    if (toRetunNotifications.count == 5 || toRetunNotifications.count == planetNotifications.count || toRetunNotifications.count == roomToPush) {
                        completion((toRetunNotifications,weightReturn))
                    } else {
                        if(notification.actionTaken! < 2) {
                            toRetunNotifications.append(notification)
                        } else {
                            //Where we can handle a new notification to be send to recommend changing their priority
                            continue
                        }
                    }
                }
                if(toRetunNotifications.count == planetNotifications.count) {
                    completion((toRetunNotifications,weightReturn))
                }
            }
        default:
            completion((toRetunNotifications,weightReturn))
        }
    }
}

enum NotificationCategory: String {
    case Contact
    case Event
    case Goal

    var titles: [String] {
        switch self {
        case .Contact:
            return ["Start the convo!", "Reminder to Reach Out", "Hit em Up!"]
        case .Event:
            return ["On the LookOut 👀", "Upcoming Event!", "Event Reminder!"]
        case .Goal:
            return ["Reach New Heights!", "Goal Reminder", "Result Check!"]
        }
    }

    var bodies: [String] {
        switch self {
        case .Contact:
            return ["You should start a message with ", "Send a chat to ", "Create A convo with"]
        case .Event:
            return ["Medium Body 1", "Medium Body 2", "Medium Body 3"]
        case .Goal:
            return ["High Body 1", "High Body 2", "High Body 3"]
        }
    }
}

