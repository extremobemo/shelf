//
//  CoreDataManager.swift
//  shelf-proj
//
//  Created by Bemo on 8/11/23.
//

import Foundation
import CoreData

class CoreDataManager {
    let persistentStoreContainer: NSPersistentContainer
    static let shared = CoreDataManager()
    
    private init() {
        persistentStoreContainer = NSPersistentContainer(name: "ShelfGamesModel")
        persistentStoreContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
      persistentStoreContainer.persistentStoreDescriptions.first?.shouldAddStoreAsynchronously = true
      persistentStoreContainer.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
      persistentStoreContainer.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true
    }
}
