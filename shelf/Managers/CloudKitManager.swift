//
//  CloudKitManager.swift
//  shelf-proj
//
//  Created by Bemo on 9/23/23.
//

import Foundation
import CloudKit
import CoreData

class CloudKitManager {
    func getGameRecord(game: Game) {
        let moby_id = game.moby_id
        let predicate = NSPredicate(format: "CD_moby_id == %lld", moby_id)
        
        let query = CKQuery(recordType: "CD_Game", predicate: predicate)
        
        let container = CKContainer(identifier: "iCloud.icloud.extremobemo.shelf-proj")
        let database = container.privateCloudDatabase // or publicCloudDatabase, depending on your needs
        var recordToDelete: CKRecord?
        database.fetch(withQuery: query, inZoneWith: nil) { result in
            switch result {
            case .success((let matchResults, _)):
                for matchResult in matchResults {
                    switch matchResult.1 { // the second item in the tuple
                    case .success(let record):
                        //return
                        recordToDelete = record
                        database.delete(withRecordID: record.recordID) { _,_ in print("DELETED") }
                    case .failure(let error): print(error)
                    } //end 2nd switch
                } //end for
            case .failure(let error):
                print(error)
            }
        }
        
            //end 1st switch
        //end fetch
        //             else if let records = records, !records.isEmpty {
        //                // You have found one or more matching records
        //                // Choose the specific record you want to delete
        //                let recordToBeDeleted = records[0] // Assuming you want to delete the first matching record
        //
        //                // Extract the record ID
        //                let recordIDToDelete = recordToBeDeleted.recordID
        //
        //                // Now you have the CKRecord.ID of the record to delete
        //                // You can call your delete function with this record ID
        //                //deleteRecordFromCloudKit(recordID: recordIDToDelete)
        
    }
}
