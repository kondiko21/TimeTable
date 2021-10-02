//
//  SingleLessonView.swift
//  Timetable 3.0
//
//  Created by Konrad on 13/03/2021.
//  Copyright © 2021 Konrad. All rights reserved.
//

import SwiftUI

struct SingleLessonView: View {
    
    var color : String
    var name : String
    var hour : String
    var room : String
    let currentWidgetText = NSLocalizedString("current_lesson_widget", comment: "")
    let endWidgetText = NSLocalizedString("lesson_end_widget", comment: "")
    let roomWidgetText = NSLocalizedString("lesson_room_widget", comment: "")
    let noLessonWidgetText = NSLocalizedString("no_lessons_widget", comment: "")
    let noLessonYetWidgetText = NSLocalizedString("no_lessons_yet_widget", comment: "")


    var body: some View {
        if name != "placeholder" {
        ZStack {
            Color(UIColor.UIColorFromString(string: color))
            VStack(alignment: .leading){
                
                Text("\(currentWidgetText):")
                if #available(iOS 14.0, *) {
                    Text(name)
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                if room != "" {
                    Text("\(roomWidgetText) \(room)")
                }
                if #available(iOS 14.0, *) {
                    Text("\(endWidgetText) \(hour)")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                }
            }
            .padding(10)
            }

        } else if name == "before_placeholder" {
            ZStack {
                VStack(alignment: .leading){
                    ZStack {
                        Color(.systemBackground)
                        Text(noLessonYetWidgetText)
                            .font(Font.system(size: 15, weight: .semibold,  design: .rounded))
                    }
                }
            }
        } else {
            ZStack {
                VStack(alignment: .leading){
                    ZStack {
                        Color(.systemBackground)
                        Text(noLessonWidgetText)
                            .font(Font.system(size: 15, weight: .semibold,  design: .rounded))
                    }
                }
            }


        }
    }
}


