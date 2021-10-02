//
//  AddLessonView.swift
//  Timetable 3.0
//
//  Created by Konrad on 23/08/2020.
//  Copyright © 2020 Konrad. All rights reserved.
//

import SwiftUI
import WidgetKit

struct EditModeView: View {
    
    var notificationManager = NotificationManager.shared
    
    @State var isFormSheetPresented = false
    @Environment(\.managedObjectContext) var moc
    @FetchRequest var day: FetchedResults<Days>
    var dayName : String
    @State var isEditPresented = false
    var dateFormatter = DateFormatter()
    var title = NSLocalizedString("Edit plan:", comment: "View Title")
    var dayNameLanguage : String
    
    
    init(dayName: String) {
        self.dayName = dayName
        self._day = FetchRequest(entity: Days.entity(), sortDescriptors: [],predicate: NSPredicate(format: "name == %@", dayName))
        dateFormatter.dateFormat = "HH:mm"
        dayNameLanguage = NSLocalizedString(dayName, comment: "")
    }
    
    
    var body: some View {
        List {
            ForEach(day.first!.lessonArray, id:\.self) { dayData in
                ZStack {
                    Color(UIColor.UIColorFromString(string: dayData.lessonModel.color))
                    HStack {
                        Text(dayData.lessonModel.name).font(Font.headline)
                            .padding(20)
                        Text(dateFormatter.string(from: dayData.startHour)).font(Font.headline)
                    }
                    NavigationLink(destination: EditLessonView(selectedLesson: dayData, selectedDay: day.first!)){
                    }.opacity(0)
                }
                .listRowInsets(EdgeInsets())
            }.onDelete(perform: self.delete)
        }
        .sheet(isPresented: $isFormSheetPresented) {
            AddLessonModalForm(showModal: $isFormSheetPresented, selectedDay: day.first!).environment(\.managedObjectContext, self.moc)
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("\(title) \(dayNameLanguage)", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            isFormSheetPresented.toggle()
            
        }, label: {
            Image(systemName: "plus.circle")
        }))
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let lesson = day.first!.lessonArray[index]
            let lessonModel = lesson.lessonModel
            lessonModel.removeFromParticularLesson(lesson)
            day.first!.removeFromLessons(lesson)
            if lessonModel.particularLesson.count == 0 {
                moc.delete(lessonModel)
                
            }
        }
        do {
            try moc.save()
            print(day.first!.name)
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
            notificationManager.updateBeforeLessonNotificationsFor(day: day.first!)
            notificationManager.updateStartLessonNotificationsFor(day: day.first!)
            
        } catch {
            print(error)
            
        }
    }
}

