//
//  TimeTable_WatchApp.swift
//  TimeTable.Watch Watch App
//
//  Created by Konrad on 06/08/2023.
//  Copyright © 2023 Konrad. All rights reserved.
//

import SwiftUI
import CoreData

@main
struct TimeTable_Watch_App: App {
    
    let context = persistentContainer.viewContext
    
    var body: some Scene {
        WindowGroup {
            MainView().environment(\.managedObjectContext, context)
        }
    }
}

var persistentContainer: NSPersistentCloudKitContainer = {
    let container = NSPersistentCloudKitContainer(name: "Timetable_3_0 v2")
    let storeURL = URL.storeURL(for: "group.com.kondiko.Timetable", databaseName: "timetable")
    let description = NSPersistentStoreDescription(url: storeURL)
    container.viewContext.automaticallyMergesChangesFromParent = true
    description.shouldMigrateStoreAutomatically = true
    description.shouldInferMappingModelAutomatically = false
    description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.kondiko.timetable.stable")
    description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        } else {
        }
    })
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
