//
//  V1ToV2MigrationPolicy.swift
//  Timetable 3.0
//
//  Created by Konrad on 15/10/2021.
//  Copyright © 2021 Konrad. All rights reserved.
//

import Foundation
import CoreData

class DaysMigrationPolicy : NSEntityMigrationPolicy {
    
    @objc func identificatorFor(id:Int16) -> UUID {
         return UUID()
     }
    
    @objc func isDisplayedWith(id:Int16) -> Bool {
         return true
     }
    
}
