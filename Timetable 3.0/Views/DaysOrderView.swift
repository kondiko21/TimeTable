//
//  DaysOrderView.swift
//  Timetable 3.0
//
//  Created by Konrad on 04/10/2021.
//  Copyright © 2021 Konrad. All rights reserved.
//

import SwiftUI

struct DaysOrderView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Days.entity(), sortDescriptors:[
        NSSortDescriptor(keyPath: \Days.number, ascending: true),
        NSSortDescriptor(keyPath:\Days.id, ascending: true )])
        var days : FetchedResults<Days>
    @Binding var orderScreenActive : Bool
    
    @State var data = ["cat", "dog", "fish"]
    
    var body: some View {
        VStack{
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
            .padding(.top, 30)
        List {
            ForEach(days, id: \.self) { day in
                HStack {
                    Image(systemName: day.isDisplayed ? "checkmark.circle.fill" : "checkmark.circle")
                        .foregroundColor(.blue)
                        .font(Font.system(size: 30))
                        .onTapGesture {
                            day.isDisplayed.toggle()
                            do {
                                try moc.save()
                            }
                            catch {
                                print(error)
                            }
                        }
                    Text("\(day.name)").font(Font.title).padding()
                }
            }
            .onMove(perform: onMove)

        }
        }
            .navigationViewStyle(.stack)
    }
    
    private func onMove(source: IndexSet, destination: Int) {
            
        var revisedItems: [ Days ] = days.map{ $0 }
        
            revisedItems.move(fromOffsets: source, toOffset: destination )
        
            for reverseIndex in stride( from: revisedItems.count - 1,
                                        through: 0,
                                        by: -1 )
            {
                    revisedItems[ reverseIndex ].number = Int16( reverseIndex )
            }
        orderScreenActive = true
        
    }
}


