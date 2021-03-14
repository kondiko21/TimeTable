//
//  SingleLessonView.swift
//  Timetable 3.0
//
//  Created by Konrad on 13/03/2021.
//  Copyright © 2021 Konrad. All rights reserved.
//

import SwiftUI

struct SingleLessonView: View {
    
    var color : String
    var name : String
    var hour : String
    var room : String
    
    var body: some View {
        ZStack {
            Color(UIColor.UIColorFromString(string: color))
            VStack(alignment: .leading){
                Text("Current lesson:")
                if #available(iOS 14.0, *) {
                    Text(name)
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Text("In room \(room)")
                Text("Ends: \(hour)").font(.title)
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.leading, 5)
            .padding(.trailing, 5)
        
    }    }
}


