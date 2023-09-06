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
import CloudKit

struct Provider: TimelineProvider {
    
    let currentWeekDay = Calendar.current.component(.weekday, from: Date())
    let moc : NSManagedObjectContext
    @AppStorage("defaultPlanId") var defaultPlanId: String = ""
    var users : [UserPlan] = []
    var currentDay : Days = Days()
    
    init() {
        moc =  persistentContainer.viewContext
        let request = NSFetchRequest<UserPlan>(entityName: "UserPlan")
        if defaultPlanId != "" {
            let predicate = NSPredicate(format: "id == %@", defaultPlanId)
            request.predicate = predicate
        }
        do {
            users  = try moc.fetch(request)
        } catch {
            print(error)
        }
        if !users.isEmpty {
            for day in users[0].daysArray {
                if day.name == Calendar.current.getNameOfWeekDayOfNumber(currentWeekDay) {
                    currentDay = day
                    break
                }
            }
        }
    }

    func placeholder(in context: Context) -> SimpleEntry {
        let color = UIColor.StringFromUIColor(color: .blue)
       print("Placeholder")
       let entry = SimpleEntry(date: Date(),startHour: Date(), endHour: Date(), color: color, name: "placeholder", room: "1")
       return entry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let color = UIColor.StringFromUIColor(color: .blue)
        
        let entry = SimpleEntry(date: Date(),startHour: Date(), endHour: Date(), color: color, name: "Math", room: "1")
        
        completion(entry)
        }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
            let startDay = Calendar.current.startOfDay(for: Date())
            let reloadDay = Calendar.current.date(byAdding: .day, value: 1, to: startDay)!
            var entries: [SimpleEntry] = []
        
        if currentDay.isDisplayed {
                
//                entries.append(beforeEntry)
                for lesson in currentDay.lessonArray {
                    let hour =  Calendar.current.component(.hour, from: lesson.startHour)
                    let minute =  Calendar.current.component(.minute, from: lesson.startHour)
                    let entryDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
                    let entry = SimpleEntry(date: entryDate,startHour: lesson.startHour, endHour: lesson.endHour, color: lesson.lessonModel.color, name: lesson.lessonModel.name, room: lesson.room)
                        entries.append(entry)
                }
                if currentDay.lessonArray.count != 0 {
                    
                    let lastLesson = currentDay.lessonArray.last
                    let lastHour =  Calendar.current.component(.hour, from: lastLesson!.endHour)
                    let lastMinute =  Calendar.current.component(.minute, from: lastLesson!.endHour)
                    let lastEntryDate = Calendar.current.date(bySettingHour: lastHour, minute: lastMinute, second: 0, of: Date())!
                    let endEntry = SimpleEntry(date: lastEntryDate,startHour: Date(), endHour: Date(), color: "red", name: "placeholder", room: "room")
                    entries.append(endEntry)
                    
                }
            } else {
                let entry = SimpleEntry(date: startDay,startHour: Date(), endHour: Date(), color: "color", name: "placeholder", room: "room")
                    entries.append(entry)
            }
            let timeline = Timeline(entries: entries, policy: .after(reloadDay))
            completion(timeline)
        }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let startHour : Date
    let endHour : Date
    let color : String
    let name : String
    let room : String
}

struct TimetableSimpleComplicationEntryView : View {
    var entry: Provider.Entry
    
    var endHour : String = ""
    var startHour : String = ""
    
    init(entry : Provider.Entry) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        endHour = formatter.string(from: entry.endHour)
        startHour = formatter.string(from: entry.startHour)
        
        self.entry = entry
    }
    var body: some View {
        SingleLessonComplicationView(color: entry.color, name: entry.name,startHour: startHour, endHour: endHour, room: entry.room)
    }
}

@main
struct MyWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TimetableCurrentLessonComplication()
    }
}

struct TimetableCurrentLessonComplication: Widget {
    let kind: String = "Widget"
    
    private var supportedFamilies: [WidgetFamily] {
            if #available(iOSApplicationExtension 16.0, *) {
                return [
                    .accessoryRectangular,
                    .accessoryInline
                ]
            } else {
                return []
            }
        }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimetableSimpleComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("Lesson Widget")
        .description("Current lesson right on your screen.")
        .supportedFamilies(supportedFamilies)
    }
}

var persistentContainer: NSPersistentCloudKitContainer = {
  
    let container = NSPersistentCloudKitContainer(name: "Timetable_3_0 v2")
    let storeURL = URL.storeURL(for: "group.com.kondiko.Timetable", databaseName: "timetable")
    let description = NSPersistentStoreDescription(url: storeURL)
    
    description.shouldMigrateStoreAutomatically = true
    description.shouldInferMappingModelAutomatically = true
    container.persistentStoreDescriptions = [description]
    description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    description.cloudKitContainerOptions = nil


    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
         
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    return container
}()

func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
           
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}


public extension URL {

static func storeURL(for appGroup: String, databaseName: String) -> URL {
    guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
        fatalError("Shared file container could not be created.")
    }

    return fileContainer.appendingPathComponent("\(databaseName).sqlite")
}
}

struct RoundedCorners: View {
    var color: Color = .black
    var tl: CGFloat = 0.0 // top-left radius parameter
    var tr: CGFloat = 0.0 // top-right radius parameter
    var bl: CGFloat = 0.0 // bottom-left radius parameter
    var br: CGFloat = 0.0 // bottom-right radius parameter
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                
                let w = geometry.size.width
                let h = geometry.size.height
                
                // We make sure the radius does not exceed the bounds dimensions
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
                
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(self.color)
        }
    }
}
