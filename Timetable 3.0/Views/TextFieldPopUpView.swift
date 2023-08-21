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
    var isClosable : Bool
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
                ZStack(alignment: .topTrailing) {
                    Color(UIColor.systemBackground)
                    HStack {
                        Spacer()
                        if isClosable {
                            Button {
                                isPresented = false
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(Color((UIColor(red: 0.27, green: 0.35, blue: 0.75, alpha: 1.00))))
                            }
                        }
                    }.padding()
                    VStack {
                        Text(headerText).font(.title).fontWeight(.semibold)
                            .foregroundColor(Color(UIColor(red: 0.27, green: 0.35, blue: 0.75, alpha: 1.00)))
                            .padding(.top, 30)
                        Text(messageText).font(.body).multilineTextAlignment(.leading)
                            .padding([.leading,.trailing], 20)
                            .padding(.top, 1)
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
                                .padding(.bottom, 30)
                        }

                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .cornerRadius(10.0)
                .padding([.leading, .trailing], 30)
                .padding(.top, geometry.size.height/5)
                .shadow(color: Color(UIColor.systemBackground).opacity(0.5), radius: 5.0, x: 4.0, y: 3.5)
            }
        }
    }
}

struct TextFieldPopUpView_Previews: PreviewProvider {
    
    @State var value : String = ""
    static var stringHander : (String) -> Void = { _ in }

    
    static var previews: some View {
        Group {
            TextFieldPopUpView(headerText: "Welcome in new version!", messageText: "Hi! We prepared new version of app that allows you to add multiple timetables. Becouse of that we would like you to ask you to type name of your current plan. ", buttonText: "Name timetable", isClosable: false, isPresented: .constant(true), didClose: stringHander)
        }
    }
}
