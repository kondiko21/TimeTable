//
//  DaysOrderView.swift
//  Timetable 3.0
//
//  Created by Konrad on 04/10/2021.
//  Copyright © 2021 Konrad. All rights reserved.
//

import SwiftUI
import CoreData

struct DaysOrderView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: UserPlan.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: nil) var users : FetchedResults<UserPlan>
    @State var selectedUser : UserPlan?
    @Binding var orderScreenActive : Bool
        
    var body: some View {
        VStack{
            HStack {
                if selectedUser != nil {
                    Text("Plan: \(selectedUser!.name)").font(.largeTitle).bold()
                        //.accessibilityAddTraits(.isHeader)
                        .padding(.top, 10)
                        .padding(.leading)
                } else {
                    Text("Days order").font(.largeTitle).bold()
                        .accessibilityAddTraits(.isHeader)
                }
                Menu {
                    ForEach (users) { user in
                        Button {
                            print("Changed user")
                            selectedUser = user
                        } label: {
                            Text(user.name)
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                Spacer()
            }
                
            }
            .onAppear {
                if !users.isEmpty { selectedUser = users.first }
            }
            OrderDayList(editedUser: selectedUser, orderScreenActive: $orderScreenActive)
        .navigationViewStyle(.stack)
    }
    
}



struct OrderDayList: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest var days: FetchedResults<Days>
    @Binding var orderScreenActive : Bool

    init(editedUser: UserPlan?, orderScreenActive : Binding<Bool>) {
        self._orderScreenActive = orderScreenActive
        if let user = editedUser {
            let predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(Days.user), user)
            self._days = FetchRequest<Days>(sortDescriptors: [NSSortDescriptor(keyPath: \Days.number, ascending: true)], predicate: predicate)
        } else {
            self._days = FetchRequest(entity: Days.entity(),sortDescriptors: [],
                                       predicate: NSPredicate(format: "name == %@", "XZY0m"))
        }
    }
    var body: some View {
        ZStack {
            HStack {
                Button {
                    orderScreenActive = false
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.blue)
                        Text("Back").foregroundColor(.black)
                            .foregroundColor(.white)
                    }
                    .frame(height:50)
                }.padding(.leading)
                Button {
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.blue)
                        EditButton()
                            .foregroundColor(.blue)
                    }
                    .frame(height:50)
                }.padding(.trailing)
            }
            .padding(.top, 10)
        }
        if !days.isEmpty {
            List {
                ForEach(days, id: \.self) { day in
                    HStack {
                        Image(systemName: day.isDisplayed ? "checkmark.circle.fill" : "checkmark.circle")
                            .foregroundColor(.blue)
                            .font(Font.system(size: 25))
                            .onTapGesture {
                                day.isDisplayed.toggle()
                                do {
                                    try moc.save()
                                }
                                catch {
                                    print(error)
                                }
                            }
                        Text("\(day.name)").font(Font.subheadline).padding()
                    }
                }
                .onMove(perform: onMove)
            }
            
        }
    }

    
    private func onMove(source: IndexSet, destination: Int) {
            
        var revisedItems: [ Days ] = days.sorted(by: { $0.number < $1.number })
        
            revisedItems.move(fromOffsets: source, toOffset: destination )
        
            for reverseIndex in stride( from: revisedItems.count - 1,
                                        through: 0,
                                        by: -1 )
            {
                    revisedItems[ reverseIndex ].number = Int16( reverseIndex )
            }
        do {
            try moc.save()
        }
        catch {
            print(error)
        }
//        orderScreenActive = true
        
    }
    
}
