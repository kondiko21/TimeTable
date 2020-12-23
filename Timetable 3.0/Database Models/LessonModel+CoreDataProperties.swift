//
//  LessonModel+CoreDataProperties.swift
//  Timetable 3.0
//
//  Created by Konrad on 20/10/2020.
//  Copyright © 2020 Konrad. All rights reserved.
//
//

import Foundation
import CoreData


extension LessonModel :Identifiable{

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LessonModel> {
        return NSFetchRequest<LessonModel>(entityName: "LessonModel")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String
    @NSManaged public var teacher: String
    @NSManaged public var color: String
    @NSManaged public var particularLesson: NSSet

}

// MARK: Generated accessors for particularLesson
extension LessonModel {

    @objc(addParticularLessonObject:)
    @NSManaged public func addToParticularLesson(_ value: Lesson)

    @objc(removeParticularLessonObject:)
    @NSManaged public func removeFromParticularLesson(_ value: Lesson)

    @objc(addParticularLesson:)
    @NSManaged public func addToParticularLesson(_ values: NSSet)

    @objc(removeParticularLesson:)
    @NSManaged public func removeFromParticularLesson(_ values: NSSet)

}

extension LessonModel {

}
