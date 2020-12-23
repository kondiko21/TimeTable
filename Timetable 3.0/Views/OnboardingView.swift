//
//  OnboardingView.swift
//  Timetable 3.0
//
//  Created by Konrad on 22/12/2020.
//  Copyright © 2020 Konrad. All rights reserved.
//

import SwiftUI

struct Page : Hashable{
    var id : Int
    var title : String
    var description : String
    var image_name : String
}


struct OnboardingView: View {
    @State var selectedTab = 0
    var data = [
    Page(id: 0, title: "Welcome to TimeTable app", description: "This app lets you to manage your or your children time in school", image_name: "logo"),
    Page(id: 1, title: "Your timetable", description: "You can add all your lessons and customize them with colors.", image_name: "add_image"),
    Page(id: 2, title: "Notifications", description: "You'll get notification when your lesson is about to start or where to go for your next class. You will never miss lesson again. \nHow cool is this!", image_name: "notification_image"),
    Page(id: 3, title: "Settings", description: "Go to settings and make the notification the most suitable for you. You can also change the dark mode!", image_name: "settings_image")
    ]

   @State var isActive = false

    var body: some View {
        NavigationView {
        if #available(iOS 14.0, *) {
            TabView(selection: $selectedTab) {
                ForEach(data, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Spacer()
                        if index.image_name == "logo" {
                            Image(index.image_name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                                .padding(.leading, 70)
                                .padding(.trailing, 70)
                                .padding(.top, 80)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                                Image(index.image_name)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.leading, 30)
                                    .padding(.trailing, 30)
                                    .padding(.bottom, 20)
                                    .padding(.top, 60)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Spacer()
                        Text(index.title)
                            .font(.title)
                            .padding(.leading, 30)
                            .padding(.trailing, 30)
                            .padding(.top, 30)
                            .foregroundColor(Color(UIColor(red: 0.27, green: 0.35, blue: 0.75, alpha: 1.00)))
                        Text(index.description)
                            .padding(.leading, 30)
                            .padding(.trailing, 30)
                            .padding(.bottom, 30)
                            .padding(.top, 15)
                        HStack {
                            Spacer()
                            if selectedTab != data.last!.id{
                                    Button(action: {
                                            withAnimation (.easeInOut(duration: 1.0)) {
                                                selectedTab += 1
                                            }
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(.largeTitle)
                                    .foregroundColor(Color.white).padding(30)
                                    .background(Circle().fill(Color(UIColor(red: 0.27, green: 0.35, blue: 0.75, alpha: 1.00))))
                                }
                                    .padding(.trailing, 15)
                                    .padding(.bottom, 15)
                            } else {
                                NavigationLink(destination: MainView()) {
                                    Image(systemName: "arrow.right")
                                        .font(.largeTitle)
                                        .foregroundColor(Color.white).padding(30)
                                        .background(Circle().fill(Color(UIColor(red: 0.27, green: 0.35, blue: 0.75, alpha: 1.00))))
                                    }
                                        .padding(.trailing, 15)
                                        .padding(.bottom, 15)
                                }
                            }
                        
                    }
                    .tag(index.id)
                    }
                }
            .tabViewStyle(PageTabViewStyle())
            .navigationBarHidden(true)

        }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
