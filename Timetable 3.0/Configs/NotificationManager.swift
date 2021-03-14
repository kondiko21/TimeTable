//
//  NotificationManager.swift
//  Timetable 3.0
//
//  Created by Konrad on 15/11/2020.
//  Copyright © 2020 Konrad. All rights reserved.
//

import Foundation
import NotificationCenter
import CoreData

final class NotificationManager {
    
    static let shared = NotificationManager()
    var beforeLessonNotificationsEnabled = UserDefaults.standard.object(forKey: "before_lesson_notification") as? Bool ?? true
    var startLessonNotificationsEnabled = UserDefaults.standard.object(forKey: "start_lesson_notification") as? Bool ?? false
    
    fileprivate  var appDelegate: AppDelegate = {
        UIApplication.shared.delegate as! AppDelegate
    }()
    var moc : NSManagedObjectContext
    let fetchRequest: NSFetchRequest<Days> = Days.fetchRequest()
    var days : [Days] = []
    private init() {
            moc = appDelegate.persistentContainer.viewContext
        do {
            days = try moc.fetch(fetchRequest)
        } catch {
            print("Error")
        }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted == true && error == nil {
                    print("Notifications permitted")
                } else {
                    print("Notifications not permitted")
                }
            }
    }
    
    var notifications = [Notification]()

    func displayNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print("NOTIFICATION: \(request.trigger)")
            }
        })
    }
    public func updateBeforeLessonNotificationsFor (day: Days) {
        if beforeLessonNotificationsEnabled {
            let settingsInterval = UserDefaults.standard.object(forKey: "notification_interval_length") as? Int ?? 5
            let notificationInterval = -settingsInterval*60
            let lessons = day.lessonArray
            if lessons.count != 0 {
                removeNotificationWithSign("B", day)
                for i in (0..<lessons.count-1) {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    var dateComponent = DateComponents()
                    let calendar = Calendar.current
                    
                    let notificationHour = lessons[i].endHour.addingTimeInterval(TimeInterval(notificationInterval))
                    dateComponent.weekday = getNumberOfWeekDayOfName(lessons[i].day.name)
                    dateComponent.hour = calendar.component(.hour, from: notificationHour )
                    dateComponent.minute = calendar.component(.minute, from: notificationHour)
                    let notification1 = NSLocalizedString("Your next lesson is", comment: "")
                    let notification2 = NSLocalizedString("and starts", comment: "")
                    let notification3 = NSLocalizedString("in room", comment: "")
                    let notification4 = NSLocalizedString("Next lesson", comment: "")

                    let content = UNMutableNotificationContent()
                    content.sound = UNNotificationSound.default
                    content.title = notification4
                    content.body = "\(notification1) \(lessons[i+1].lessonModel.name) \(notification2) \(dateFormatter.string(from: lessons[i+1].startHour)) \(notification3) \(lessons[i+1].room)."
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
                    let request  = UNNotificationRequest(identifier: "\(lessons[i].id.uuidString)B", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    //print("ACTION: Updating before lesson notification... \(dateComponent)")
                }
            }
            
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests(completionHandler: { requests in
                for _ in requests {
                 //   print("NUMBER \(request.trigger)")
                }
            })
        }
    }
    
    func updateAllBeforeLessonNotifications() {
        if beforeLessonNotificationsEnabled {
            for day in days {
                updateBeforeLessonNotificationsFor(day: day)
            }
            //print("ACTION: Updating before lesson notification...")
        }
    }
    
    func updateAllStartLessonNotifications() {
        if startLessonNotificationsEnabled {
            for day in days {
                updateStartLessonNotificationsFor(day: day)
            }
        }
    }
    
    
    public func updateStartLessonNotificationsFor(day: Days) {
        if startLessonNotificationsEnabled {
            let lessons = day.lessonArray
            if lessons.count != 0 {
                
                removeNotificationWithSign("S", day)
                for lesson in lessons {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    var dateComponent = DateComponents()
                    let calendar = Calendar.current
                    
                    dateComponent.weekday = getNumberOfWeekDayOfName(lesson.day.name)
                    dateComponent.hour = calendar.component(.hour, from: lesson.startHour )
                    dateComponent.minute = calendar.component(.minute, from: lesson.startHour )
                    
                    let notification2 = NSLocalizedString("is about to start.", comment: "")
                    let notification1 = NSLocalizedString("Next lesson", comment: "")
                    
                    let content = UNMutableNotificationContent()
                    content.sound = UNNotificationSound.default
                    content.title = notification1
                    content.body = "\(lesson.lessonModel.name) \(notification2)"
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
                    let request  = UNNotificationRequest(identifier: "\(lesson.id.uuidString)S", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                   // print("ACTION: Updating start lesson notification...")

                    
                }
            }
            
//            let center = UNUserNotificationCenter.current()
//            center.getPendingNotificationRequests(completionHandler: { requests in
//                for request in requests {
//                    print("NUMBERX \(request.trigger)")
//                }
//            })
        }
    }
    
    func removeAllNotificationsWithSign(_ sign : String) {
        for day in days {
            removeNotificationWithSign(sign, day)
        }
    }
    
    func removeNotificationWithSign(_ sign : String, _ day : Days) {
        let lessons = day.lessonArray
        var IDs = lessons.map {$0.id.uuidString}
        for i in 0..<IDs.count {
            IDs[i] = IDs[i] + sign
           // print(IDs[i] + sign)
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: IDs)
    }
        
    func getNumberOfWeekDayOfName(_ name : String) -> Int {
        
        if name == "Monday" {
            return 2
        }
        if name == "Tuesday" {
            return 3
        }
        if name == "Wednesday" {
            return 4
        }
        if name == "Thursday" {
            return 5
        }
        if name == "Friday" {
            return 6
        }
        return 0
        
    }
}
