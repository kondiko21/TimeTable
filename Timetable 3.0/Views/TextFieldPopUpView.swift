//
//  TextFieldPopUpView.swift
//  Timetable 3.0
//
//  Created by Konrad on 13/09/2022.
//  Copyright © 2022 Konrad. All rights reserved.
//

import SwiftUI

struct TextFieldPopUpView: View {
    
    var headerText : String
    var messageText : String
    var buttonText : String
    @State var textFieldValue : String = ""
    @Binding var isPresented : Bool

    var didClose : (String) -> Void
    
//    init(headerText: String, messageText: String, buttonText: String, textFieldValue: Binding<String>, isPresented: Binding<Bool>) {
//        self.headerText = headerText
//        self.messageText = messageText
//        self.buttonText = buttonText
//        self._textFieldValue = textFieldValue
//        self._isPresented = isPresented
//    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()
            GeometryReader { geometry in
                ZStack {
                    Color(UIColor.systemBackground)
                    VStack {
                        Text(headerText).font(.title).bold()
                            .foregroundColor(Color(UIColor(red: 0.27, green: 0.35, blue: 0.75, alpha: 1.00)))
                        Text(messageText).font(.body).padding(.top).multilineTextAlignment(.leading)
                            .padding(5)
                        TextField("Name", text: $textFieldValue)    .textFieldStyle(.roundedBorder)
                            .padding([.leading, .trailing], 30)
                            .padding(.top, 10)
                        Button {
                            didClose(textFieldValue)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                textFieldValue = ""
                            }
                        } label: {
                            ZStack {
                                Color((UIColor(red: 0.27, green: 0.35, blue: 0.75, alpha: 1.00)))
                                    .cornerRadius(10)
                                    .padding([.leading, .trailing],40)
                                    .frame(height:50)
                                Text(buttonText).foregroundColor(.primary)
                            }.padding(.top)
                        }

                    }
                    .padding(5)
                }
                .cornerRadius(8.0)
                .padding([.top, .bottom], geometry.size.height/4)
                .padding([.leading, .trailing], 30)
                .shadow(color: Color(UIColor.systemBackground).opacity(0.5), radius: 5.0, x: 4.0, y: 3.5)
            }
        }
    }
}

//struct TextFieldPopUpView_Previews: PreviewProvider {
//    
//    @State var value : String = ""
//    
//    static var previews: some View {
//        Group {
//            TextFieldPopUpView(headerText: "Welcome in new version!", messageText: "Hi! We prepared new version of app that allows you to add multiple timetables. Becouse of that we would like you to ask you to type name of your current plan. ", buttonText: "Name timetable", textFieldValue: .constant("test"), isPresented: .constant(true))
//        }
//    }
//}
