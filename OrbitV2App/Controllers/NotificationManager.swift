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
    //This runs at the loading start of new app load
    func onStartConfig(planetList: [Planet: [Notification]]) {
        var currentlyPushed: Int = 0
        //setting the days left in this month
        grabNotificationPushers() {(request) in
            currentlyPushed = request.count
            print("Here are the pushed initally: \(currentlyPushed)")
            if request.isEmpty{
                self.setNotificationPusher(planetList: planetList)
            } else if(request.count > self.throttle) {
                self.removeNotificationPushArray(notificationArray: request)
                self.setNotificationPusher(planetList: planetList)
            }
            //TODO: run a configuration check to see how many we have que'd up for this user. Making sure it doesn't exceed
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
            return (day, month, year, totalDaysInMonth, daysLeftInMonth)
        }
    
    func setNotificationPusher(planetList: [Planet: [Notification]]) {
        //create the tuple
        var rawNotifications: (notificationList: [Notification], notificationWeight: String) = ([], "")
        //set the array to hold the tuples
        var organizedNotifications = [rawNotifications]
        //loop through each planet
        for (planet, _) in planetList {
            let planetPositions = planet.position
            setNotificationsOrbit(planetPositon: planetPositions!, planetList: planetList, currentPlanet: planet) {(orbitTuple) in
                rawNotifications.notificationList = orbitTuple.0
                rawNotifications.notificationWeight = orbitTuple.1
                organizedNotifications.append(rawNotifications)
            }
        }
        transformNotificationsForPush(organizedNotifications)
    }
    
    func transformNotificationsForPush(_ organizedNotifications: [(notificationList: [Notification], notificationWeight: String)]){
        var transformedNotifications: [UNMutableNotificationContent] = []
        let currentDateInfo = getCurrentDate()
        for tuple in organizedNotifications {
            transformedNotifications = []
            let notificationList = tuple.notificationList
            let notificationWeight = tuple.notificationWeight
            
            switch notificationWeight {
            case "small":
                for notification in notificationList {
                    let content = UNMutableNotificationContent()
                    content.title = notification.title
                    content.body = notification.description!
                    content.sound = .default
                    transformedNotifications.append(content)
                }
                smallNotificationPusher(notificationList: transformedNotifications, currentDateInfo: currentDateInfo)
            case "medium":
                for notification in notificationList {
                    let content = UNMutableNotificationContent()
                    content.title = notification.title
                    content.body = notification.description!
                    content.sound = .default
                    transformedNotifications.append(content)
                }
                mediumNotificationPusher(notificationList: transformedNotifications, currentDateInfo: currentDateInfo)
            case "high":
                for notification in notificationList {
                    let content = UNMutableNotificationContent()
                    content.title = notification.title
                    content.body = notification.description!
                    content.sound = .default
                    transformedNotifications.append(content)
                }
                highNotificationPusher(notificationList: transformedNotifications, currentDateInfo: currentDateInfo)
            default:
                break
            }
        }
    }
    
    private func smallNotificationPusher(notificationList: [UNMutableNotificationContent], currentDateInfo: (day: Int, month: Int, year: Int, totalDaysInMonth: Int, daysLeftInMonth: Int)) {
        var dayCounterCheck = currentDateInfo.day
        var NotificationsArrayToPush: [UNNotificationRequest] = []
        var currentMonth = currentDateInfo.month
        var currentYear = currentDateInfo.year
        for content in notificationList {
            let randomShortDate = Int.random(in: 1...5)
            let notificationIdentifier = UUID().uuidString
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
                let notificationToPush = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
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
                let notificationToPush = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                NotificationsArrayToPush.append(notificationToPush)
                dayCounterCheck += 5
            }
        }
        self.createNotificationPush(toBePushed: NotificationsArrayToPush)
    }
    
    private func mediumNotificationPusher(notificationList: [UNMutableNotificationContent], currentDateInfo: (day: Int, month: Int, year: Int, totalDaysInMonth: Int, daysLeftInMonth: Int)) {
        var dayCounterCheck = currentDateInfo.day
        var NotificationsArrayToPush: [UNNotificationRequest] = []
        var currentMonth = currentDateInfo.month
        var currentYear = currentDateInfo.year
        
        for content in notificationList {
            
            let randomWeekDay = Int.random(in: 1...14)
            let notificationIdentifier = UUID().uuidString
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
                let notificationToPush = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
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
                let notificationToPush = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                NotificationsArrayToPush.append(notificationToPush)
                dayCounterCheck += 14
            }
        }
        self.createNotificationPush(toBePushed: NotificationsArrayToPush)
    }
    
    private func highNotificationPusher(notificationList: [UNMutableNotificationContent], currentDateInfo: (day: Int, month: Int, year: Int, totalDaysInMonth: Int, daysLeftInMonth: Int)) {
        var NotificationsArrayToPush: [UNNotificationRequest] = []
        var currentMonth = currentDateInfo.month
        var currentYear = currentDateInfo.year
        for content in notificationList {
            let randomDayOfMonth = Int.random(in: 1...currentDateInfo.totalDaysInMonth)
            let notificationIdentifier = UUID().uuidString
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
            let notificationToPush = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
            NotificationsArrayToPush.append(notificationToPush)
        }
        self.createNotificationPush(toBePushed: NotificationsArrayToPush)
    }
    
    func updateNotificationPusher() {
        
    }
    
    private func createNotificationPush(toBePushed: [UNNotificationRequest]) {
        let connection = UNUserNotificationCenter.current()
        for notification in toBePushed {
            connection.add(notification) { (error: Error?) in
                if let error = error {
                    print("Error: \(error.localizedDescription) for the notification: \(notification.content.title)")
                }
            }
        }
    }
    
    //To remove all notification
    private func removeNotificationPushArray(notificationArray: [UNNotificationRequest]) {
        let connection = UNUserNotificationCenter.current()
        let identifiers = notificationArray.map { $0.identifier }
        connection.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    //Remove single notification
    func removeIndividaulNotification(notification: UNNotificationRequest){
        
    }
    
    func addIndividualNotification(notification: UNNotificationRequest) {
        
    }
    
    func testThisOut() {
        let connection = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        content.title = "Orbit Reminder"
        content.body = "Reach out to Steve this week!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let pushing = UNNotificationRequest(identifier: "test1", content: content, trigger: trigger)
        
        connection.add(pushing) { (error: Error?) in
            if let error = error {
                print("Error: \(error.localizedDescription) for the notification: \(pushing.content.title)")
            }
        }
    }
    
    
    private func grabNotificationPushers(completion: @escaping ([UNNotificationRequest]) -> Void) {
        let connection = UNUserNotificationCenter.current()
        connection.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            completion(requests)
        }
    }
    
    private func setNotificationsOrbit(planetPositon: Int, planetList: [Planet: [Notification]], currentPlanet: Planet, completion: @escaping (([Notification],String)) -> Void ) {
        var toRetunNotifications: [Notification] = []
        var weightReturn: String = ""
        //INFO: We are grabbing based on the planets position and adding the weight to return in a tuple for us to use to sort out the notifications info that will be pushed.
        switch planetPositon {
        case 1:
            weightReturn = "small"
            if var planetNotifications = planetList[currentPlanet] {
                planetNotifications.sort{$0.priority < $1.priority}
                for notification in planetNotifications {
                    if toRetunNotifications.count == 5 || toRetunNotifications.count == planetNotifications.count {
                        completion((toRetunNotifications,weightReturn))
                    } else {
                        toRetunNotifications.append(notification)
                    }
                }
            }
        case 2:
            weightReturn = "medium"
            if var planetNotifications = planetList[currentPlanet] {
                planetNotifications.sort{$0.priority < $1.priority}
                for notification in planetNotifications {
                    if toRetunNotifications.count == 3 || toRetunNotifications.count == planetNotifications.count {
                        completion((toRetunNotifications,weightReturn))
                    } else {
                        toRetunNotifications.append(notification)
                    }
                }
            }
        case 3:
            weightReturn = "high"
            if var planetNotifications = planetList[currentPlanet] {
                planetNotifications.sort{$0.priority < $1.priority}
                for notification in planetNotifications {
                    if toRetunNotifications.count == 2 || toRetunNotifications.count == planetNotifications.count {
                        completion((toRetunNotifications,weightReturn))
                    } else {
                        toRetunNotifications.append(notification)
                    }
                }
            }
        default:
            completion((toRetunNotifications,weightReturn))
        }
    }
    
}
