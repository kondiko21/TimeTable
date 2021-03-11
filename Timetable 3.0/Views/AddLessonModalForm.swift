//
//  AddLessonModalView.swift
//  Timetable 3.0
//
//  Created by Konrad on 09/11/2020.
//  Copyright © 2020 Konrad. All rights reserved.
//

import SwiftUI
import WidgetKit

struct AddLessonModalForm: View {
     
    @Binding var showModal: Bool
    @State var selectedDay: Days
    @State var isPickerChanged = false
    @State var lessonExist = false
    @State var name = ""
    @State var teacher = ""
    @State var room = ""
    @State var id : UUID = UUID()
    @State var modelLesson: LessonModel = LessonModel()
    @State var createdLesson: Lesson = Lesson()
    @State var startHour: Date = Date()
    @State var endHour: Date = Date()
    @State var selectedColor: Color = Color.blue
    @State var isAlertPresented = false
    @State var isMissingDataAlertPresented = false
    @State private var intersectionLesson: [Lesson] = []
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: LessonModel.entity(), sortDescriptors: []) var lessons : FetchedResults<LessonModel>
    var lessonTime : Int = (UserDefaults.standard.object(forKey: "lesson_length") as? Int ?? 45) * 60

    var notificationManager = NotificationManager.shared

    var body: some View {
    NavigationView {
        Form {
            Toggle(isOn: $lessonExist ) { Text("Never used lesson") }
                if lessonExist {
                    
                    Section(header: Text("Primary informations").font(Font.headline)) {
                        TextField("Name", text: $name)
                        TextField("Teacher", text: $teacher)
                    }
                    
                    Section(header: Text("Pick color").font(Font.headline)) {
                        if #available(iOS 14.0, *) {
                            ColorPicker("Set the background color", selection: $selectedColor)
                        } else {
                            Text("In iOS 14 or higher you can select your own color")
                        }
                    }
                } else {
                    if #available(iOS 14.0, *) {
                        Picker(selection: $modelLesson, label: Text("Lessons")) {
                            ForEach(lessons, id: \.self) { lesson in
                                HStack {
                                    Text(lesson.name)
                                    Spacer()
                                    Text(lesson.teacher)
                                }
                            }
                        }
                        .onChange(of: modelLesson) { (newValue) in
                            isPickerChanged = true
                        }
                    }
                }
                Section(header: Text("Informations").font(Font.headline)) {
                    TextField("Room", text: $room)
                    if #available(iOS 14.0, *) {
                    DatePicker("Start lesson", selection: $startHour, displayedComponents: .hourAndMinute)
                        .onChange(of: startHour) { (newValue) in
                            endHour = startHour.addingTimeInterval(TimeInterval(lessonTime))
                        }
                     
                     DatePicker("End lesson", selection: $endHour, displayedComponents: .hourAndMinute)
                        .onChange(of: endHour) { (newValue) in
                            startHour = endHour.addingTimeInterval(-TimeInterval(lessonTime))
                        }
                    }
                }
                Button(action: {
                    intersectionLesson = checkTimeAvailability(startHour, endHour, selectedDay, nil)
                    if(intersectionLesson.isEmpty) {
                        addLesson()
                    } else {
                        isAlertPresented.toggle()
                    }
                }) {
                    Text("Add lesson")
                }
                .alert(isPresented: $isMissingDataAlertPresented, content: { () -> Alert in
                    let cancelButton = Alert.Button.default(Text("Close")) {
                        isMissingDataAlertPresented.toggle()
                    }
                    return Alert(title: Text("Missing data"), message: Text("There are missing data in your form or some of them are incorrect. Please fill every field and try again."), dismissButton: cancelButton)
                })
        }
        .navigationBarTitle("Add lesson", displayMode: .automatic)
        .navigationBarItems(trailing: Button(action: { showModal.toggle()}
                                             , label: {
                                                Text("Close")
                                             }))
        
        .alert(isPresented: $isAlertPresented, content: { () -> Alert in
            let cancelButton = Alert.Button.default(Text("Change time")) {
                intersectionLesson = []
                isAlertPresented = false
            }
            
            let removeButton = Alert.Button.default(Text("Remove")) {
                removeInterruptingLessons(lessons: intersectionLesson)
                addLesson()
                isAlertPresented.toggle()
            }
            var intersectString : String = ""
            for object in intersectionLesson {
                intersectString += object.lessonModel.name+", "
            }
            intersectString.removeLast(2)
            return Alert(title: Text("Incorrect lesson hours"), message: Text("There are other lessons in time you selected for this lesson: \(intersectString)\n Do you want to change hours of this lesson or remove interrupting lesson?"), primaryButton: cancelButton, secondaryButton: removeButton)
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
    
    func addLesson() {
        
        var correctData = true;
        if self.lessonExist {
            if room.isEmpty || name.isEmpty || teacher.isEmpty || endHour == startHour  { correctData = false }
            else {
                let lesson = Lesson(context: self.moc)
                lesson.endHour = self.endHour
                lesson.startHour = self.startHour
                lesson.room = self.room
                lesson.id = UUID()
                id = lesson.id
                lesson.lessonModel = LessonModel(context: self.moc)
                lesson.lessonModel.name = self.name
                lesson.lessonModel.teacher = self.teacher
                if #available(iOS 14.0, *) {
                    lesson.lessonModel.color = UIColor.StringFromUIColor(color: UIColor(selectedColor))
                }
                lesson.day = self.selectedDay
            }
            
        } else {
            if room.isEmpty || isPickerChanged == false || endHour == startHour {
                correctData = false
            }
            else {
                let lesson = Lesson(context: self.moc)
                lesson.endHour = self.endHour
                lesson.id = UUID()
                self.id = lesson.id
                lesson.startHour = self.startHour
                lesson.room = self.room
                lesson.lessonModel = self.modelLesson
                lesson.day = self.selectedDay
            }
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
            showModal.toggle()
        
        }
        else {
            isMissingDataAlertPresented.toggle()
        }
    }
}

func checkTimeAvailability(_ start : Date, _ end : Date, _ day : Days, _ editedLesson : Lesson?) -> [Lesson] {
    let primaryInterval = DateInterval(start: start, end: end)
    var intersectingLesson : [Lesson] = []
    for lesson in day.lessonArray {
        if editedLesson != lesson || editedLesson == nil {
            let checkInterval = DateInterval(start: lesson.startHour, end: lesson.endHour)
            if primaryInterval.intersects(checkInterval) {
                intersectingLesson.append(lesson)
            }
        }
    }
    return intersectingLesson
}



public extension UIColor {

    class func StringFromUIColor(color: UIColor) -> String {
        let components = color.cgColor.components
        return "[\(components![0]), \(components![1]), \(components![2]), \(components![3])]"
    }
    
    class func UIColorFromString(string: String) -> UIColor {
        let componentsString = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let components = componentsString.split(separator: ",")
        return UIColor(red: CGFloat((components[0] as NSString).floatValue),
                     green: CGFloat((components[1] as NSString).floatValue),
                      blue: CGFloat((components[2] as NSString).floatValue),
                     alpha: CGFloat((components[3] as NSString).floatValue))
    }
    
}

