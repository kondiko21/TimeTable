//
//  SingleLessonView.swift
//  Timetable 3.0
//
//  Created by Konrad on 13/03/2021.
//  Copyright © 2021 Konrad. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SingleLessonComplicationView: View {
    
    @Environment(\.widgetFamily) private var family
    
    var color : String
    var name : String
    var startHour : String
    var endHour : String
    var room : String
    let currentWidgetText = NSLocalizedString("current_lesson_widget", comment: "")
    let roomWidgetText = NSLocalizedString("lesson_room_widget", comment: "")
    let noLessonWidgetText = NSLocalizedString("no_lessons_widget", comment: "")
    let noLessonYetWidgetText = NSLocalizedString("no_lessons_yet_widget", comment: "")


    var body: some View {
        if name != "placeholder" {
            switch family {
            case .accessoryInline:
                HStack {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(Color(UIColor.UIColorFromString(string: color)))
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.body)
                        Text("\(startHour) - \(endHour)")
                            .font(.body)
                    }
                }
            case .accessoryRectangular:
                VStack(alignment: .leading) {
                        Text(name)
                            .font(.headline)
                            .bold()
                        if room != "" {
                            Text("\(roomWidgetText) \(room)")
                                .font(.body)
                        }
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.body)
                        Text("\(startHour) - \(endHour)")
                            .font(.body)
                    }
                    }
                    
            default:
                EmptyView()
            }
        }
            else {
                switch family {
                case .accessoryInline:
                    Text(noLessonWidgetText)
                        .font(.headline)
                case .accessoryRectangular:
                    Text(noLessonWidgetText)
                        .font(.headline)
                default:
                    EmptyView()
                }
            }
        }
    }

