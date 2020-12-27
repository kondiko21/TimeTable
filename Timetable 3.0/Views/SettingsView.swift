//
//  SettingsView.swift
//  Timetable 3.0
//
//  Created by Konrad on 24/11/2020.
//  Copyright © 2020 Konrad. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    private var states = ["Dark", "Light", "Automatically"]
    @State private var colorSchemeSelected = 0
    @ObservedObject var userSettings = Settings()

    var body: some View {
        Form {
            Section(footer: Text("You need to restart your app to see changes.")) {
                HStack {
                    Text("Color mode")
                    Spacer()
                    Picker(selection: $userSettings.selectedColorScheme, label:
                            Text("Color mode"), content: {
                                ForEach( 0 ..< states.count, id: \.self) {
                                    Text(self.states[$0])
                                        .padding()
                                }
                            })
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 130, height: 30)
                        .clipped()
                        .labelsHidden()
                }
                
            }
            Section(footer: Text("Value works only while you're setting your scheulde")) {
                HStack {
                    Text("Lesson length")
                    Spacer()
                    TextField("", value: $userSettings.lessonLength, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 40, height: 34)
                        .clipped()
                    Text(" minutes")

                }
            }
            Section(footer: Text("Set the interval for the amount of minutes before the end of the lesson.")) {
                HStack {
                    Text("Notification interval")
                    Spacer()
                    TextField("", value: $userSettings.notificationIntervalLength, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 40, height: 34)
                        .clipped()
                    Text(" minutes")

                }
            }
            Section {
                Toggle(isOn: $userSettings.beforeLessonNotificationsEnabled) {
                    Text("Enable next lesson notification")
                }
                Toggle(isOn: $userSettings.startLessonNotificationsEnabled) {
                    Text("Enable lesson beggining notification")
                }
            }
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                }
            }
            .navigationBarTitle("Settings", displayMode: .automatic)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
