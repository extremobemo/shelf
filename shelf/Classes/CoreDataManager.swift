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
  static let shared = CoreDataManager()
  
  lazy var persistentStoreContainer: NSPersistentCloudKitContainer = {
    
    let container = NSPersistentCloudKitContainer(name: "ShelfGamesModel")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    try? container.viewContext.setQueryGenerationFrom(.current)
    
    return container
    
  }()
  
  private init() {
    
    let bundleIdentifier = "extremobemo.shelf-proj"
    
    if let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      // Construct the URL for the Core Data store file
      let storeURL = applicationSupportDirectory.appendingPathComponent(bundleIdentifier)
      
      // Now, storeURL points to the directory where your Core Data SQLite database file may be stored.
      print("Core Data store directory URL: \(storeURL.path)")
    }
  }
}
