//
//  EditLessonView.swift
//  Timetable 3.0
//
//  Created by Konrad on 10/11/2020.
//  Copyright © 2020 Konrad. All rights reserved.
//

import SwiftUI
import WidgetKit

struct EditLessonView: View {
    
    @State var selectedLesson: Lesson
    @State var selectedDay: Days
    var notificationManager = NotificationManager.shared
    @State var selectedColor = Color.blue
    @State private var startHour: Date
    @State private var endHour: Date
    @State var modelLesson: LessonModel = LessonModel()
    @State var isAlertPresented = false
    @State var isMissingDataAlertPresented = false
    @State var intersectionLesson: [Lesson] = []
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: LessonModel.entity(), sortDescriptors: []) var lessons : FetchedResults<LessonModel>
    
    init(selectedLesson: Lesson, selectedDay: Days) {
        self._selectedDay = State(initialValue: selectedDay)
        self._selectedLesson = State(initialValue: selectedLesson)
        _selectedColor = State(initialValue: Color(UIColor.UIColorFromString(string: selectedLesson.lessonModel.color)))
        _startHour =  State(initialValue: selectedLesson.startHour)
        _endHour =  State(initialValue: selectedLesson.endHour)
    }
    
    
    var lessonTime: Int = 45
    var body: some View {
        if #available(iOS 14.0, *) {
            Form {
                Section(header: Text("Primary informations").font(Font.headline).padding(.top, 20)) {
                    TextField("Name", text: $selectedLesson.lessonModel.name)
                    TextField("Teacher", text: $selectedLesson.lessonModel.teacher)
                }
                Section(header: Text("Pick color").font(Font.headline)) {
                        ColorPicker("Set the background color", selection: $selectedColor)
                }
                Section(header: Text("Informations").font(Font.headline)) {
                    TextField("Room", text: $selectedLesson.room)
                    DatePicker("Start lesson", selection: $startHour, displayedComponents: .hourAndMinute)
                            .onChange(of: startHour) { (newValue) in
                                endHour = startHour.addingTimeInterval(TimeInterval(lessonTime*60))
                            }
                    DatePicker("End lesson", selection: $endHour, displayedComponents: .hourAndMinute)
                }
                Button(action: {
                    if selectedLesson.startHour != startHour || selectedLesson.endHour != endHour {
                        intersectionLesson = checkTimeAvailability(startHour, endHour, selectedDay, selectedLesson)
                    }
                    selectedLesson.startHour = startHour
                    selectedLesson.endHour = endHour
                    selectedLesson.lessonModel.color = UIColor.StringFromUIColor(color: UIColor(selectedColor))
                    if(intersectionLesson.isEmpty) {
                        updateContext()
                    } else {
                        isAlertPresented.toggle()
                    }
                }) {
                    Text("Edit lesson")
                }
            }
            .navigationBarTitle(selectedLesson.lessonModel.name, displayMode: .inline)
            .alert(isPresented: $isMissingDataAlertPresented, content: { () -> Alert in
                let cancelButton = Alert.Button.default(Text("Close")) {
                    isMissingDataAlertPresented.toggle()
                }
                return Alert(title: Text("Missing data"), message: Text("There are missing data in your form. Please fill every field and try again."), dismissButton: cancelButton)
            })
            .alert(isPresented: $isAlertPresented, content: { () -> Alert in
                print("Alert: \(intersectionLesson)")
                let cancelButton = Alert.Button.default(Text("Change time")) {
                    intersectionLesson = []
                    isAlertPresented = false
                }
                let removeButton = Alert.Button.default(Text("Remove")) {
                    removeInterruptingLessons(lessons: intersectionLesson)
                    updateContext()
                    isAlertPresented.toggle()
                }
                var intersectString : String = ""
                for object in intersectionLesson {
                    intersectString += object.lessonModel.name+", "
                }
                intersectString.removeLast(2 )
                return Alert(title: Text("Incorrect lesson hours"), message: Text("There are other lessons int time you elected for this lesson: \(intersectString)\n Do you want to change hours of this lesson or remove interrupting lesson?"), primaryButton: cancelButton, secondaryButton: removeButton)
            })
        }
    }
    
    func removeInterruptingLessons(lessons: [Lesson]) {
        for lesson in lessons {
            let lessonModel = lesson.lessonModel
            lessonModel.removeFromParticularLesson(lesson)
            selectedDay.removeFromLessons(lesson)
            if lessonModel.particularLesson.count == 0 && modelLesson != lessonModel {
                moc.delete(lessonModel)
            }
        }
        do {
            try moc.save()

        }
        catch {
            print(error)
        }
    }
    
    func updateContext() {
        
        if #available(iOS 14.0, *) {
            selectedLesson.lessonModel.color = UIColor.StringFromUIColor(color: UIColor(selectedColor))
        }
        var correctData: Bool = true
        
        if selectedLesson.lessonModel.name.isEmpty || selectedLesson.lessonModel.teacher.isEmpty || selectedLesson.room.isEmpty {
            correctData = false
        }
        
        if correctData {
            do {
                try self.moc.save()
            } catch {
                print(error)
            }
            moc.refreshAllObjects()
            notificationManager.updateBeforeLessonNotificationsFor(day: selectedDay)
            notificationManager.updateStartLessonNotificationsFor(day: selectedDay)
            notificationManager.displayNotifications()
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
            self.presentationMode.wrappedValue.dismiss()
        }
        else {
            isMissingDataAlertPresented.toggle()
        }
    }
    
}

