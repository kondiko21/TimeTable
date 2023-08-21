//
//  LoadingView.swift
//  Timetable 3.0
//
//  Created by Konrad on 31/07/2023.
//  Copyright © 2023 Konrad. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .scaleEffect(4)
                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.27, green: 0.35, blue: 0.75)))
            Rectangle().frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .opacity(0.2)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
