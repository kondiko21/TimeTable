//
//  ContentView.swift
//  Timetable 3.0
//
//  Created by Konrad on 20/08/2020.
//  Copyright © 2020 Konrad. All rights reserved.
//

import SwiftUI
import CoreData

struct MainView: View {
    
    
    @Environment(\.managedObjectContext) var moc
    @Environment (\.colorScheme) var colorScheme:ColorScheme
    @FetchRequest(entity: Days.entity(), sortDescriptors: [NSSortDescriptor(key: "id", ascending: true)]) var days : FetchedResults<Days>
    let title = NSLocalizedString("Lesson plan", comment: "Title")

    init() {
        
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
        
    }
    
    var body: some View {
        
        NavigationView {
        ScrollView{
            if #available(iOS 14.0, *) {
                ScrollViewReader { value in
                        ForEach(days, id:\.self) { day in
                            VStack(alignment: .leading,spacing: 0) {
                                ZStack {
                                    HStack(alignment: .center, spacing: 10) {
                                        Text(day.name)
                                            .fontWeight(.semibold)
                                            .font(Font.system(size: 15))
                                            .padding(.leading, 12)
                                            .foregroundColor(Color(UIColor.systemGray))
                                        Spacer()
                                        NavigationLink(destination: EditModeView(dayName: day.name)) {
                                            
                                            Image(systemName: "square.and.pencil").resizable()
                                                .font(Font.title.weight(.semibold))
                                                .frame(width: 15, height: 15, alignment: .center)
                                                .foregroundColor(Color(UIColor.systemGray))
                                        }.padding(10)
                                        
                                    }.frame(width: UIScreen.main.bounds.width)
                                }.padding(.top, 10)
                                ForEach(day.lessonArray, id: \.self) { lesson in
                                    LessonPlanElement(lesson: lesson)
                                }
                            }.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .id(getNumberOfWeekDayOfName(day.name))
                        }
                        .onAppear {
                            let myDate = Date()
                            let currentWeekDay = Calendar.current.component(.weekday, from: myDate)
                            if !(2...6).contains(currentWeekDay) {
                                value.scrollTo(currentWeekDay)
                            } else {
                                value.scrollTo(2)
                            }
                        }
                        .navigationBarTitle(title, displayMode: .automatic)
                        .navigationBarItems(trailing:
                                NavigationLink(destination: SettingsView()){
                                        Image(systemName: "gear")
                                            .resizable()
                                            .frame(width: 24, height: 24, alignment: .center)
                                            .foregroundColor(Color.iconColor(for: colorScheme))
                                })
                }
            }
        }
    }
        .navigationBarHidden(true)
    }
}
func getNumberOfWeekDayOfName(_ name : String) -> Int {
    
    if name == "Monday" {
        return 2
    }
    if name == "Tuesday" {
        return 3
    }
    if name == "Wednesday" {
        return 4
    }
    if name == "Thursday" {
        return 5
    }
    if name == "Friday" {
        return 6
    }
    return 0
    
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


struct LessonPlanElement: View {
    
    var roomTitle = NSLocalizedString("Room",comment: "Room name")
    var lesson: Lesson
    var name: String = "Unnamed"
    let dateFormatter = DateFormatter()
    
    init(lesson : Lesson) {
        self.lesson = lesson
        dateFormatter.dateFormat = "HH:mm"
    }
    
        var body: some View {
            ZStack{
                HStack(spacing: 0){
                    RoundedCorners(color: Color(UIColor.UIColorFromString(string: lesson.lessonModel.color)).opacity(1.0), tl: 10, bl: 10).frame(width: 15)
                    RoundedCorners(color: Color(UIColor.UIColorFromString(string: lesson.lessonModel.color)).opacity(0.3), tr: 10, br: 10)
                }.frame(height: 110)
                VStack{
                    HStack(alignment: .top){
                        VStack(alignment: .leading) {
                        Text(lesson.lessonModel.name)
                            .font(Font.system(size: 20, weight: .semibold))
                            
                        Text(lesson.lessonModel.teacher)
                            .font(Font.system(size: 15, weight: .light))
                        }
                        .padding(.leading, 20)
                        .padding(.top, 10)
                        Spacer()
                        Text("\(roomTitle) \(lesson.room)")
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                            .font(Font.system(size: 15, weight: .light))
                    }
                    Spacer()
                    HStack(alignment: .bottom){
                        Text("\(dateFormatter.string(from: lesson.startHour)) - \(dateFormatter.string(from: lesson.endHour))")
                            .padding(.leading, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .font(Font.system(size: 15, weight: .light))
                        Spacer()
                    }
                }
                }.padding(.leading, 10)
                .padding(.trailing, 10)
                .padding(.bottom, 10)
                .cornerRadius(5)
            
        }
        }

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate)
              .persistentContainer.viewContext
        return MainView()
                  .environment(\.managedObjectContext, context)
    }
}


extension Color {
    static let black = Color.black
    static let white = Color.white

    static func iconColor(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return white
        } else {
            return black
        }
    }
}
