import Foundation
import Combine

class Settings: ObservableObject {
    
    
    var notificationManager = NotificationManager()

    @Published var lessonLength: Int {
        didSet {
            UserDefaults.standard.set(lessonLength, forKey: "lesson_length")
            print("XZX")

        }
    }
    
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
    
    init() {
        
        self.lessonLength = UserDefaults.standard.object(forKey: "lesson_length") as? Int ?? 45
        self.notificationIntervalLength = UserDefaults.standard.object(forKey: "notification_interval_length") as? Int ?? 5
        self.selectedColorScheme = UserDefaults.standard.object(forKey: "color_scheme") as? Int ?? 2
        self.beforeLessonNotificationsEnabled = UserDefaults.standard.object(forKey: "before_lesson_notification") as? Bool ?? true
        self.startLessonNotificationsEnabled = UserDefaults.standard.object(forKey: "start_lesson_notification") as? Bool ?? false

    }
}
