//
//  WatchConnectionPhone.swift
//  Timetable 3.0
//
//  Created by Konrad on 06/08/2023.
//  Copyright © 2023 Konrad. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnectionPhone : NSObject,  WCSessionDelegate{
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    var session: WCSession = .default
    
    override init(){
        
        super.init()
        
        session.delegate = self
        self.session = WCSession.default
        session.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        print("ACTIVATED SESSION")
        
    }
    
    func updateDefaultId(id: String) {
        do {
            try session.updateApplicationContext(["defaultId" : id])
            print("ID SENT")
        } catch {
            print("COMMUNICATION ERROR:")
            print(error)
        }
    }
}
