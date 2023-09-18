import Foundation
import UIKit
import Combine
import CoreData

class Settings: ObservableObject {
    
    fileprivate  var appDelegate: AppDelegate = {
        UIApplication.shared.delegate as! AppDelegate
    }()
    var moc : NSManagedObjectContext
    let fetchRequest: NSFetchRequest<UserPlan> = UserPlan.fetchRequest()
    var users : [UserPlan] = []
    
    var notificationManager = NotificationManager.shared
    
    private var defaultPlanId = UserDefaults(suiteName: "group.com.kondiko.Timetable")?.string(forKey: "defaultPlanId")
    
    @Published var notificationIntervalLength: Int {
        didSet {
            UserDefaults.standard.set(notificationIntervalLength, forKey: "notification_interval_length")
            notificationManager.updateAllBeforeLessonNotifications()
        }
    }
    
    @Published var selectedColorScheme: Int {
        didSet {
            UserDefaults.standard.set(selectedColorScheme, forKey: "color_scheme")
        }
    }
    
    @Published var beforeLessonNotificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(beforeLessonNotificationsEnabled, forKey: "before_lesson_notification")
            if beforeLessonNotificationsEnabled {
                notificationManager.updateAllBeforeLessonNotifications()
            } else {
                notificationManager.removeAllNotificationsWithSign("B")
            }
        }
    }
    
    @Published var startLessonNotificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(startLessonNotificationsEnabled, forKey: "start_lesson_notification")
            if startLessonNotificationsEnabled {
                notificationManager.updateAllStartLessonNotifications()
            } else {
                notificationManager.removeAllNotificationsWithSign("S")
            }
        }
    }
    
    @Published var lessonLength: Int {
        didSet {
            UserDefaults.standard.set(lessonLength, forKey: "lesson_length")
            print("XZX")

        }
    }
    
    @Published var modifiedLesson : Bool = true
    
    init() {
        
        self.lessonLength = UserDefaults.standard.object(forKey: "lesson_length") as? Int ?? 45
        self.notificationIntervalLength = UserDefaults.standard.object(forKey: "notification_interval_length") as? Int ?? 5
        self.selectedColorScheme = UserDefaults.standard.object(forKey: "color_scheme") as? Int ?? 2
        self.beforeLessonNotificationsEnabled = UserDefaults.standard.object(forKey: "before_lesson_notification") as? Bool ?? true
        self.startLessonNotificationsEnabled = UserDefaults.standard.object(forKey: "start_lesson_notification") as? Bool ?? false

        //Fetch data to process resetAppData() function
        moc = appDelegate.persistentContainer.viewContext
        do {
            users = try moc.fetch(fetchRequest)
        } catch {
            print("Error")
        }
        
    }
    
    func resetAppData() {
        print(users.count)
        for user in users {
            if user.daysArray.isEmpty {
                moc.delete(user)
            }
            if !users.isEmpty {
                if let userDefaults = UserDefaults(suiteName: "group.com.kondiko.Timetable") {
                    userDefaults.setValue(users[0].id.uuidString, forKey: "defaultPlanId")
                }
            }
        }
        if defaultPlanId != "" {
            print("XX")
            for user in users {
                print(user.id.uuidString)
                if user.id.uuidString == defaultPlanId {
                    moc.delete(user)
                }
            }
            for day in users[0].daysArray {
                for lesson in day.lessonArray {
                    moc.delete(lesson)
                }
            }
        }
        do {
            try moc.save()
        } catch {
            print("Error during reseting plan")
        }
    }
}
