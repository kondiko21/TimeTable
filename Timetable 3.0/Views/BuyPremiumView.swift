//
//  BuyPremiumView.swift
//  SubShare
//
//  Created by Konrad on 02/03/2022.
//

import SwiftUI

struct BuyPremiumView: View {
    
    @State var cost : String = ""
    @EnvironmentObject var storeManager : StoreManager
    @Binding var presentationMode : Bool
    @AppStorage("com.kondiko.Timetable.plus") var premiumUser : Bool = false

    var body: some View {
        GeometryReader {georeader in
            VStack {
                HStack(alignment: .center) {
                    Image("pro_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                        .padding(.top, 90)
                        .frame(width: georeader.size.width*0.7,height: georeader.size.width*0.7)
                }
                Text("Timetable+").font(.largeTitle).bold().foregroundColor( Color(UIColor(red: 0.27, green: 0.35, blue: 0.75, alpha: 1.00)))
                    .padding(.top, 40)
                Text("Timetable + offers you non limited amount of timtables added. \n Lifetime.").font(.title2).bold().padding().multilineTextAlignment(.center)
                Spacer()
                Button {
                    if let product = storeManager.products.first {
                        storeManager.purchaseProduct(product: product)
                    } else {
                        fatalError("Couldn't find product.")
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundColor(Color(UIColor(red: 0.27, green: 0.35, blue: 0.75, alpha: 1.00)))
                        Text("Buy for \(cost)").bold().padding().foregroundColor(Color.black)
                    }
                    .frame(height: 50)
                    .padding()
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
                }
                .navigationBarItems(trailing: Button(action: {
                    presentationMode = false
                }, label: {
                    Text("Back")
                }))
                .onChange(of: premiumUser) { value in
                    if value {
                        presentationMode = false
                    }
                }
            }
        }
        .onAppear {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = storeManager.products.first!.priceLocale
            cost = formatter.string(from: storeManager.products.first!.price)!
        }
    }
}
