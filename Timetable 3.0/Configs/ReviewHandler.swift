//
//  ReviewHandler.swift
//  Timetable 3.0
//
//  Created by Konrad on 09/08/2023.
//  Copyright © 2023 Konrad. All rights reserved.
//

import Foundation
import StoreKit
import SwiftUI

class ReviewHandler {
    
    static func requestReview() {
        
        if UserDefaults.standard.integer(forKey: "completedRequiredActions") > 10 && UserDefaults.standard.integer(forKey: "countAskingForReview") == 0 {
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "countAskingForReview") + 1, forKey: "countAskingForReview")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
}
