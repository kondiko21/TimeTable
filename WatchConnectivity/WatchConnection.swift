//
//  WatchConnection.swift
//  Timetable 3.0
//
//  Created by Konrad on 06/08/2023.
//  Copyright © 2023 Konrad. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnection : NSObject,  WCSessionDelegate, ObservableObject{
    
    @Published var defaultPlanId : String = ""
    
    var session: WCSession = .default
    override init(){
        super.init()
        self.session = .default
        self.session.delegate = self
        session.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        defaultPlanId = applicationContext["defaultId"] as! String
        print("DID RECIVED: "+defaultPlanId)
        UserDefaults.standard.set(defaultPlanId, forKey: "defaultPlanId")
    }
    
}
