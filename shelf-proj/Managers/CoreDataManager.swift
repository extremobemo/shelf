//
//  CoreDataManager.swift
//  shelf-proj
//
//  Created by Bemo on 8/11/23.
//

import Foundation
import CoreData
import CloudKit

class CoreDataManager {
    let persistentStoreContainer: NSPersistentCloudKitContainer
    static let shared = CoreDataManager()
    
    private init() {
       
        
        persistentStoreContainer = NSPersistentCloudKitContainer(name: "ShelfGamesModel")
        persistentStoreContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
      persistentStoreContainer.persistentStoreDescriptions.first?.shouldAddStoreAsynchronously = true
      persistentStoreContainer.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
      persistentStoreContainer.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true

        NotificationCenter.default.addObserver(self, selector: #selector(handleEnvironmentReset), name: .CKAccountChanged, object: nil)
        
        let bundleIdentifier = "extremobemo.shelf-proj"

        if let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            // Construct the URL for the Core Data store file
            let storeURL = applicationSupportDirectory.appendingPathComponent(bundleIdentifier)

            // Now, storeURL points to the directory where your Core Data SQLite database file may be stored.
            print("Core Data store directory URL: \(storeURL.path)")
        }
    }
    
    @objc func handleEnvironmentReset() {
        if let storeURL = persistentStoreContainer.persistentStoreDescriptions.first?.url {
            do {
                // Destroy (delete) the SQLite persistent store
                try persistentStoreContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, type: .sqlite, options: nil)
            } catch {
                // Handle any errors that occur during the destruction process
                print("Error destroying persistent store: \(error.localizedDescription)")
            }
        }
    }
//    _url    NSURL    "file:///Users/the_power/Library/Containers/extremobemo.shelf-proj/Data/Library/Application%20Support/extremobemo.shelf-proj"    0x00006000012253e0
    
}
