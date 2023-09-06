//
//  ContentView.swift
//  TimeTable.Watch Watch App
//
//  Created by Konrad on 06/08/2023.
//  Copyright © 2023 Konrad. All rights reserved.
//

import SwiftUI
import CloudKit
import CoreData
import Foundation

struct MainView: View {
    
    let currentWeekDay = Calendar.current.component(.weekday, from: Date())
    @AppStorage("defaultPlanId") var defaultPlanId: String = ""
    @FetchRequest(entity: UserPlan.entity(), sortDescriptors: [], predicate: nil) var users : FetchedResults<UserPlan>
    @State var currentDay : Days?
    @State var defaultUser : UserPlan?
    @State var selected : UUID = UUID()
    @ObservedObject var connectionManager = WatchConnection()
    
    var body: some View {
        if users.isEmpty {
            VStack(alignment: .center) {
                Text("Please, run iPhone app to sync the data")
            }
        } else {
            ScrollViewReader { value in
                ScrollView {
                    if let user = defaultUser {
                        ForEach(user.daysArray, id: \.id) { day in
                            if day.isDisplayed {
                            VStack {
                                HStack {
                                    Text(day.name)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                ForEach(day.lessonArray, id: \.id) { lesson in
                                    LessonView(lesson: lesson, selected: $selected)
                                }
                                Divider()
                            }
                            .id(day.id)
                        }
                    }
                }
                }.onAppear {
                    value.scrollTo(Calendar.current.getAppNumberOfWeekdayFromWeekday(currentWeekDay))
                    print("UUID \(defaultPlanId)")
                    if !users.isEmpty {
                        for user in users {
                            if user.id.uuidString == defaultPlanId {
                                defaultUser = user
                            }
                        }
                    }
                }
            }
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct LessonView: View {
    
    var lesson : Lesson
    let dateFormatter = DateFormatter()
    @Binding var selected : UUID
    
    init(lesson : Lesson, selected: Binding<UUID>) {
        self.lesson = lesson
        dateFormatter.dateFormat = "HH:mm"
        self._selected = selected
    }
    
    var body: some View {
        ZStack {
            RoundedCorners(color: Color(UIColor.UIColorFromString(string: lesson.lessonModel.color)), tl: 10, tr: 10, bl: 10, br: 10)
            VStack {
                Text(lesson.lessonModel.name)
                    .shadow(color: .black, radius: 4.0)
                if lesson.id == selected {
                    Text("\(dateFormatter.string(from: lesson.startHour)) - \(dateFormatter.string(from: lesson.endHour))")       .shadow(color: .black, radius: 4.0)
                    Text("Room: \(lesson.room)")
                        .shadow(color: .black, radius: 4.0)
                }
            }.padding()
        }.onTapGesture {
            withAnimation {
                if selected == lesson.id {
                    selected = UUID()
                } else {
                    selected = lesson.id
                }
            }
        }
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
