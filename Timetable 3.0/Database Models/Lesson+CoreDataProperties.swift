//
//  Lesson+CoreDataProperties.swift
//  Timetable 3.0
//
//  Created by Konrad on 02/10/2021.
//  Copyright © 2021 Konrad. All rights reserved.
//
//

import Foundation
import CoreData


extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var endHour: Date
    @NSManaged public var id: UUID
    @NSManaged public var room: String
    @NSManaged public var startHour: Date
    @NSManaged public var day: Days
    @NSManaged public var lessonModel: LessonModel

}
