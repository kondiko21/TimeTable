//
//  Days+CoreDataProperties.swift
//  Timetable 3.0
//
//  Created by Konrad on 15/10/2021.
//  Copyright © 2021 Konrad. All rights reserved.
//
//

import Foundation
import CoreData


extension Days: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Days> {
        return NSFetchRequest<Days>(entityName: "Days")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isDisplayed: Bool
    @NSManaged public var name: String
    @NSManaged public var number: Int16
    @NSManaged public var lessons: NSSet
    
    public var lessonArray: [Lesson] {
           let set = lessons as? Set<Lesson> ?? []
           return set.sorted {
            $0.startHour < $1.startHour
           }
       }
}

// MARK: Generated accessors for lessons
extension Days {

    @objc(addLessonsObject:)
    @NSManaged public func addToLessons(_ value: Lesson)

    @objc(removeLessonsObject:)
    @NSManaged public func removeFromLessons(_ value: Lesson)

    @objc(addLessons:)
    @NSManaged public func addToLessons(_ values: NSSet)

    @objc(removeLessons:)
    @NSManaged public func removeFromLessons(_ values: NSSet)

}
