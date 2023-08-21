//
//  SettingsView.swift
//  Timetable 3.0
//
//  Created by Konrad on 24/11/2020.
//  Copyright © 2020 Konrad. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    private var states = [
        NSLocalizedString("Dark", comment: ""),
        NSLocalizedString("Light", comment: ""),
        NSLocalizedString("Automatically", comment: "")
    ]
    @AppStorage("com.kondiko.Timetable.plus") var premiumUser : Bool = false
    @ObservedObject var userSettings = Settings()
    @State var colorSchemeSelected = 0
    @State var orderScreenActive  = false
    @State var isBuyPremiumPresented: Bool = false
    
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
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 140, height: 30)
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
                Button {
                    orderScreenActive = true
                } label: {
                    Text("Days order")
                }
                if !premiumUser {
                    Button {
                        isBuyPremiumPresented = true
                    } label: {
                        Text("Plans management")
                    }.sheet(isPresented: $isBuyPremiumPresented) {
                        BuyPremiumView(presentationMode: $isBuyPremiumPresented)
                    }
                } else {
                    NavigationLink {
                        EditPlansView()
                    } label: {
                        Button {
                        } label: {
                            Text("Plans management")
                            
                        }
                    }
                }
            }
            
            Section {
                Button {
                    StoreManager().restoreProducts()
                   } label: {
                       Text("Restore Premium")
                   }
               }
            
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(appVersion!)  |  build \(appBuildVersion!)")
                }
            }
            .navigationBarTitle("Settings", displayMode: .automatic)
            .sheet(isPresented: $orderScreenActive) {
                DaysOrderView(orderScreenActive: $orderScreenActive)
            }
        }
    }
}
