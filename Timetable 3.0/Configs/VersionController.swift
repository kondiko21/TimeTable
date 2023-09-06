//
//  VersionController.swift
//  Timetable 3.0
//
//  Created by Konrad on 15/09/2022.
//  Copyright © 2022 Konrad. All rights reserved.
//

import Foundation
import CloudKit

final class VersionController {
    
    static let shared = VersionController()
    
    private let allVersions = ["1.0", "1.1"]
    
    var previousVersion = UserDefaults.standard.object(forKey: "CurrentVersionNumberUI") as? String
    var currnentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    func firstLaunchOfThisVersion() -> Bool {
        previousVersion = UserDefaults.standard.object(forKey: "CurrentVersionNumberUI") as? String
        currnentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        if currnentVersion != previousVersion {
            return true
        } else {
            return false
        }
    }
    func updateVersion() {
        UserDefaults.standard.set(currnentVersion, forKey: "CurrentVersionNumberUI")
    }
    
    func isOlderThan(version: String) -> Bool {
        return true
        
    }
    
    func noteFirstSync() {
        let recordID = CKRecord.ID(recordName: "preloadingComplete")
        let record = CKRecord(recordType: "preloadingComplete", recordID: recordID)
        CKContainer(identifier: "iCloud.com.kondiko.timetable.stable").privateCloudDatabase.save(record) { record, error in
            if let error = error {
                    print(error)
                    return
            }
            print("First iCloud sync has been made")
        }
    }
    
    func checkPreloadingStatus(completion: @escaping (Bool) -> Void) {
        let recordID = CKRecord.ID(recordName: "preloadingComplete")
        CKContainer(identifier: "iCloud.com.kondiko.timetable.stable").privateCloudDatabase.fetch(withRecordID: recordID) { record, error in
            if record == nil {
                // The 'preloadingComplete' record exists, so preloading has been completed.
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    public func checkRemoteData(completion: @escaping (Bool) -> ()) {
        let db = CKContainer(identifier: "iCloud.com.kondiko.timetable.stable").privateCloudDatabase
        let predicate = NSPredicate(format: "CD_entityName = 'Days'")
        let query = CKQuery(recordType: .init("CD_Days"), predicate: predicate)
        db.perform(query, inZoneWith: nil) { result, error in
            if error == nil {
                if let records = result, !records.isEmpty {
                    completion(true)
                } else {
                    print("XXXX")
                    completion(false)
                }
            } else {
                print(error as Any)
                completion(false)
            }
        }
    }
}
