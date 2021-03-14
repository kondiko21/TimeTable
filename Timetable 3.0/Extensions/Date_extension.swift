//
//  Date_extension.swift
//  Timetable 3.0
//
//  Created by Konrad on 12/03/2021.
//  Copyright © 2021 Konrad. All rights reserved.
//

import Foundation

extension Date {
    
    func timetableDate(date: Date) -> Date {
        var hourComponent = Calendar.current.dateComponents([.hour, .minute], from: date)
        hourComponent.year = 2000
        hourComponent.month = 1
        hourComponent.day = 1
        let hourData : Date = Calendar.current.date(from: hourComponent)!
        return hourData
    }
    
}
