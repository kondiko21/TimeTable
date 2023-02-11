//
//  UserPlan+CoreDataProperties.swift
//  Timetable 3.0
//
//  Created by Konrad on 17/09/2022.
//  Copyright © 2022 Konrad. All rights reserved.
//
//

import Foundation
import CoreData


extension UserPlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPlan> {
        return NSFetchRequest<UserPlan>(entityName: "UserPlan")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var weekdays: NSSet?

    public var daysArray: [Days] {
           let set = weekdays as? Set<Days> ?? []
           return set.sorted {
            $0.id < $1.id
           }
       }
}

// MARK: Generated accessors for weekdays
extension UserPlan {

    @objc(addWeekdaysObject:)
    @NSManaged public func addToWeekdays(_ value: Days)

    @objc(removeWeekdaysObject:)
    @NSManaged public func removeFromWeekdays(_ value: Days)

    @objc(addWeekdays:)
    @NSManaged public func addToWeekdays(_ values: NSSet)

    @objc(removeWeekdays:)
    @NSManaged public func removeFromWeekdays(_ values: NSSet)

}

extension UserPlan : Identifiable {

}
