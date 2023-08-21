//
//  EditPlansView.swift
//  Timetable 3.0
//
//  Created by Konrad on 01/08/2023.
//  Copyright © 2023 Konrad. All rights reserved.
//

import SwiftUI
import CoreData

class AlertContent: ObservableObject {
    
    var title : String = ""
    var message : String = ""
    var buttonText : String = ""
    
    func displayAlert(title: String, message: String, buttonText: String, display: @escaping () -> ()) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        
        display()
    }
}

final class EditPlansViewModel: ObservableObject {
    
    fileprivate  var appDelegate: AppDelegate = {
        UIApplication.shared.delegate as! AppDelegate
    }()
    
    @Published var plans: [UserPlan] = []
    @Published var defaultPlan: UserPlan?
    @Published var displayAlert : Bool = false
    
    @ObservedObject var alertManager = AlertContent()
    var connectionManager : WatchConnectionPhone?

    @AppStorage("defaultPlanId", store: UserDefaults(suiteName: "group.com.kondiko.Timetable")) var defaultPlanId: String = ""
       
       init() {
           connectionManager = WatchConnectionPhone()
           fetchData()
           
           if let userDefaults = UserDefaults(suiteName: "group.com.kondiko.Timetable") {
               let value = userDefaults.string(forKey: "defaultPlanId")
               for plan in plans {
                   if plan.id.uuidString == value {
                       defaultPlan = plan
                   }
               }
           }
       }
       
       func fetchData() {
           let request = NSFetchRequest<UserPlan>(entityName: "UserPlan")
           
           do {
               plans = try appDelegate.persistentContainer.viewContext.fetch(request)
           } catch {
               print("DEBUG: Some error occured while fetching")
           }
       }
    
    func saveData() {
        do {
            try self.appDelegate.persistentContainer.viewContext.save()
        } catch {
            print(error)
        }
    }

    func delete(plan: UserPlan) {
        
        if plans.count != 1 {

            if let index = plans.firstIndex(of: plan) {
                plans.remove(at: index) // array is now ["world"]
                setAsDefault(plan: plans[0])
                defaultPlan = plans[0]
            }
            self.appDelegate.persistentContainer.viewContext.delete(plan)
            do {
                try self.appDelegate.persistentContainer.viewContext.save()
            } catch {
                print(error)
            }
        } else {
            alertManager.displayAlert(title: "Warning", message: "You can't remove last plan. \nPlease, rename existing one.", buttonText: "") {
                self.displayAlert = true
            }
        }
    }
    
    func setAsDefault(plan: UserPlan) {
        if let userDefaults = UserDefaults(suiteName: "group.com.kondiko.Timetable") {
            userDefaults.setValue(plan.id.uuidString, forKey: "defaultPlanId")
        }
        connectionManager!.updateDefaultId(id: plan.id.uuidString)
        NotificationManager.shared.updateAllNotifications()
    }
    
}

struct EditableText: View {
    
    @State var text: String

    @State private var isFocused: Bool = false
    @State private var saveChanges : (String) -> ()
    
    internal init(text: String, saveChanges: @escaping (String) -> ()) {
        self._text = State(initialValue: text)
        self.saveChanges = saveChanges
    }

    var body: some View {
        if !isFocused {
            TextField("", text: Binding(get: {text}, set: { newValue in self.text = newValue}), onCommit: {
                if text.count != 0 {
                    saveChanges(text);
                    isFocused = false
                }
            })
        } else {
            Text(text)
                .onTapGesture { isFocused = true }
        }
    }
}

struct EditPlansView: View {
    
    
    @ObservedObject var viewModel = EditPlansViewModel()
    
    var testData = ["Konrad", "Hubert", "Adam"]
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.plans, id:\.self) { plan in
                if !plan.isFault {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(
                                RadialGradient(colors: [Color(red: 0.12, green: 0.09, blue: 0.22), Color(red: 0.27, green: 0.35, blue: 0.75)], center: .topLeading, startRadius: 20, endRadius: 850))
                        HStack {
                            EditableText(text: plan.name) { newName in
                                plan.name = newName
                                viewModel.saveData()
                            }
                            .font(Font.headline)
                            .foregroundColor(Color(red: 255, green: 255, blue: 255))
                            .shadow(color: Color(red: 0, green: 0, blue: 0), radius: 4.0)
                            .padding(20)
                            Spacer()
                            Button {
                                viewModel.setAsDefault(plan: plan)
                            } label: {
                                if plan.id.uuidString == viewModel.defaultPlanId {
                                    Image(systemName: "star.fill")
                                        .font(Font.system(size: 20))
                                        .accentColor(Color(red: 1.00, green: 0.94, blue: 0.00))
                                        .shadow(color: Color(red: 1.00, green: 0.94, blue: 0.00), radius: 0.7)
                                } else {
                                    Image(systemName: "star")
                                        .font(Font.system(size: 20))
                                        .accentColor(Color(red: 1.00, green: 0.94, blue: 0.00))
                                        .shadow(color: Color(red: 1.00, green: 0.94, blue: 0.00), radius: 0.7)
                                }
                            }
                            .padding(.trailing, 10)
                            
                            ZStack {
                                Circle()
                                    .frame(height:35)
                                    .foregroundColor(Color.white)
                                    .opacity(0.1)
                                    .shadow(color: Color.black, radius: 0.3)
                                Button {
                                    viewModel.delete(plan: plan)
                                } label: {
                                    Image(systemName: "trash.fill")
                                        .font(Font.system(size: 20))
                                        .accentColor(Color(red: 0.77, green: 0.13, blue: 0.20))
                                }
                            }
                            .padding(.trailing)
                            
                        }
                    }
                    .padding([.leading, .trailing], 15)
                    .listRowInsets(EdgeInsets())
                }
            }
            HStack(alignment: .center) {
                Text("Tap name to edit").font(Font.footnote).foregroundColor(.gray)
            }
        }
        .navigationTitle("Plans management")
        .navigationBarTitleDisplayMode(.large)
        .alert(isPresented: $viewModel.displayAlert) {
            Alert(title: Text(viewModel.alertManager.title), message: Text(viewModel.alertManager.message))
        }
    }
}

struct EditPlansView_Previews: PreviewProvider {
    static var previews: some View {
        EditPlansView()

    }
}
