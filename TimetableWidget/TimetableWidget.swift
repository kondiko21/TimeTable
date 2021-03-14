//
//  TimetableWidget.swift
//  TimetableWidget
//
//  Created by Konrad on 06/03/2021.
//  Copyright © 2021 Konrad. All rights reserved.
//

import WidgetKit
import SwiftUI
import CoreData

var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
    */
    let container = NSPersistentContainer(name: "Timetable_3_0")
    let storeURL = URL.storeURL(for: "group.com.kondiko.Timetable", databaseName: "timetable")
    let description = NSPersistentStoreDescription(url: storeURL)
    container.persistentStoreDescriptions = [description]

    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    return container
}()

// MARK: - Core Data Saving support

func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}


public extension URL {

/// Returns a URL for the given app group and database pointing to the sqlite database.
static func storeURL(for appGroup: String, databaseName: String) -> URL {
    guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
        fatalError("Shared file container could not be created.")
    }

    return fileContainer.appendingPathComponent("\(databaseName).sqlite")
}
}

struct Provider: TimelineProvider {
    
    let currentWeekDay = Calendar.current.component(.weekday, from: Date())
    let moc : NSManagedObjectContext
    var day : [Days] = []
    init() {
        moc =  persistentContainer.viewContext
        let weekday = Calendar.current.component(.weekday, from: Date())
        let predicate = NSPredicate(format: "name == %@", Calendar.current.getNameOfWeekDayOfNumber(6))
        let request = NSFetchRequest<Days>(entityName: "Days")
        request.predicate = predicate
        do {
            day = try moc.fetch(request)
        } catch {
            print(error)
        }
        print("REQUEST \(day)")
    }

    func placeholder(in context: Context) -> SimpleEntry {
        let color = UIColor.StringFromUIColor(color: UIColor.systemBlue)
       
       let entry = SimpleEntry(date: Date(), endHour: Date(), color: color, name: "placeholder", room: "1")
       return entry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
         let color = UIColor.StringFromUIColor(color: UIColor.systemBlue)
        
        let entry = SimpleEntry(date: Date(), endHour: Date(), color: color, name: "Math", room: "1")
        
        completion(entry)
        }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
            var entries: [SimpleEntry] = []
            print( "test \(day)")
            if (2...6).contains(6) {
                for lesson in day[0].lessonArray {
                    let hour =  Calendar.current.component(.hour, from: lesson.startHour)
                    let minute =  Calendar.current.component(.minute, from: lesson.startHour)
                    let entryDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
                    let entry = SimpleEntry(date: entryDate, endHour: lesson.endHour, color: lesson.lessonModel.color, name: lesson.lessonModel.name, room: lesson.room)
                        entries.append(entry)
                }
            }
            let startDay = Calendar.current.startOfDay(for: Date())
            let reloadDay = Calendar.current.date(byAdding: .day, value: 1, to: startDay)!
            let timeline = Timeline(entries: entries, policy: .after(reloadDay))
            completion(timeline)
        }
}

struct AllLessonsProvider: TimelineProvider {
    
    let currentWeekDay = Calendar.current.component(.weekday, from: Date())
    let moc : NSManagedObjectContext
    var day : [Days] = []
    init() {
        moc =  persistentContainer.viewContext
        let weekday = Calendar.current.component(.weekday, from: Date())
        let predicate = NSPredicate(format: "name == %@", Calendar.current.getNameOfWeekDayOfNumber(6))
        let request = NSFetchRequest<Days>(entityName: "Days")
        request.predicate = predicate
        do {
            day = try moc.fetch(request)
        } catch {
            print(error)
        }
    }

    func placeholder(in context: Context) -> LessonsDayEntry {
       let entry = LessonsDayEntry(date: Date(), lessons: [])
       return entry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LessonsDayEntry) -> ()) {
                
        let entry = LessonsDayEntry(date: Date(),lessons: day[0].lessonArray)
        completion(entry)
        }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
            var entries: [LessonsDayEntry] = []
            
            let startDay = Calendar.current.startOfDay(for: Date())
            let reloadDay = Calendar.current.date(byAdding: .day, value: 1, to: startDay)!
            if (2...6).contains(6) {
                let entity = LessonsDayEntry(date: Date() ,lessons: day[0].lessonArray)
                entries.append(entity)
            } else {
                print("Zero lessons")
                let entity = LessonsDayEntry(date: Date() ,lessons: [])
                entries.append(entity)
            }
            let timeline = Timeline(entries: entries, policy: .after(reloadDay))
            completion(timeline)
        }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let endHour : Date
    let color : String
    let name : String
    let room : String
}

struct LessonsDayEntry: TimelineEntry {
    let date: Date
    let lessons : [Lesson]
}

struct TimetableWidgetEntryView : View {
    var entry: Provider.Entry
    
    var hour : String = ""
    
    init(entry : Provider.Entry) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        hour = formatter.string(from: entry.endHour)
        
        self.entry = entry
    }
    var body: some View {
        SingleLessonView(color: entry.color, name: entry.name, hour: hour, room: entry.room)
    }
}

struct TimetableAllLessonsView : View {
    var entry: AllLessonsProvider.Entry
    
    var hour : String = ""
    var lessonHours : [UUID : String] = [:]
    init(entry : AllLessonsProvider.Entry) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        for lesson in entry.lessons {
            hour += formatter.string(from: lesson.startHour)
            hour += " - "
            hour += formatter.string(from: lesson.endHour)
            lessonHours[lesson.id] = hour
            hour = ""
        }
        
        self.entry = entry
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(.systemBackground)
                Spacer()
                if entry.lessons.count != 0 {
                VStack(alignment: .leading, spacing: 0){
                    ForEach(entry.lessons, id: \.self) { lesson in
                        ZStack {
                            Color(UIColor.UIColorFromString(string:lesson.lessonModel.color))
                            HStack(alignment: .center) {
                                Text(lesson.lessonModel.name)
                                    .font(.system(.body, design: .rounded))
                                    .bold()
                                Spacer()
                                Text(lessonHours[lesson.id]!)
                            }.padding()
                        }
                    }
                    .frame(height:geo.size.height/8)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    Text("No lessons today!")
                }
                
        }
    }
    }
}

@main
struct MyWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TimetableCurrentLesson()
        TimetableNextLessons()
    }
}

struct TimetableCurrentLesson: Widget {
    let kind: String = "TimetableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimetableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Lesson Widget")
        .description("Current lesson right on your screen.")
        .supportedFamilies([.systemSmall])
    }
}
struct TimetableNextLessons: Widget {
    let kind: String = "TimetableLessonsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AllLessonsProvider()) { entry in
            TimetableAllLessonsView(entry: entry)
        }
        .configurationDisplayName("Lessons Widget")
        .description("All lessons right on your screen.")
        .supportedFamilies([.systemLarge])
    }
}

public extension UIColor {

    class func StringFromUIColor(color: UIColor) -> String {
        let components = color.cgColor.components
        return "[\(components![0]), \(components![1]), \(components![2]), \(components![3])]"
    }
    
    class func UIColorFromString(string: String) -> UIColor {
        let componentsString = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let components = componentsString.split(separator: ",")
        return UIColor(red: CGFloat((components[0] as NSString).floatValue),
                     green: CGFloat((components[1] as NSString).floatValue),
                      blue: CGFloat((components[2] as NSString).floatValue),
                     alpha: CGFloat((components[3] as NSString).floatValue))
    }
    
}
