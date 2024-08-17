//
//  ShelfModel.swift
//  shelf-proj
//
//  Created by Bemo on 8/11/23.
//

import Foundation
import CoreData
import CloudKit
import SwiftUI

class ShelfModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
  
  let itemController: NSFetchedResultsController<Game>
  let shelfItemController: NSFetchedResultsController<CustomShelf>

  @Published var games: [Game] = []
  @Published var shelves: [CustomShelf] = []
  
  @Published var years: [Int64] = []
  
  private let context: NSManagedObjectContext
  
  init(context: NSManagedObjectContext) {
    self.context = context
    let fetchRequest = NSFetchRequest<Game>(entityName: "Game")
    let shelfFetchRequest = NSFetchRequest<CustomShelf>(entityName: "CustomShelf")
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Game.title, ascending: true)]
    shelfFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CustomShelf.name, ascending: true)]
    
    itemController = NSFetchedResultsController(fetchRequest: fetchRequest, 
                                                managedObjectContext: context,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
    
    shelfItemController = NSFetchedResultsController(fetchRequest: shelfFetchRequest,
                                                managedObjectContext: context,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
    
    super.init()
    itemController.delegate = self
    shelfItemController.delegate = self
    
    do {
      try itemController.performFetch()
      try shelfItemController.performFetch()
      games = itemController.fetchedObjects ?? []
      shelves = shelfItemController.fetchedObjects ?? []
      years = getAllYears()
    } catch {
      print("failed to fetch items")
    }
  }
  
  func createNewShelf(shelfName: String) async -> Void {
    if let entityDescription = NSEntityDescription.entity(forEntityName: "CustomShelf", in: CoreDataManager.shared.persistentStoreContainer.viewContext) {
      let newShelf = NSManagedObject(entity: entityDescription, insertInto: nil) as! CustomShelf

      do {
        newShelf.name = shelfName
        newShelf.game_ids = []
        
        await self.context.perform {
          self.context.insert(newShelf)
        }
        
        try self.context.save()
      } catch {
        // UnknownError.unknown(description: "Error building CoreData Game object")
      }
    }
  }
  
  func getAllCustomShelves() -> [Shelf] {
    var platforms: [Shelf] = []
    let request: NSFetchRequest<CustomShelf> = CustomShelf.fetchRequest()
    request.returnsObjectsAsFaults = false
    
    do {
      if let shelves = shelfItemController.fetchedObjects {
        for shelf in shelves {
          platforms.append(Shelf(name: shelf.name, platform_id: nil, customShelf: shelf))
        }
      }
    }
    return platforms
  }
  
  func addGamesToShelf(shelf: Shelf, games: [Game]) {
    
    let name = shelf.name!
    
    let fetchRequest : NSFetchRequest<CustomShelf> = CustomShelf.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "name == %@", name)
    let results = try? context.fetch(fetchRequest)
    if let container = results?.first {
      if container.game_ids != nil {
        container.game_ids! += games.filter {
          !container.game_ids!.contains(Int($0.moby_id))
        }.map { Int($0.moby_id) }
      } else {
        container.game_ids! = games.map { Int($0.moby_id) }
      }
     
       try? context.save()
    }
  }
  
  
  
  func addGame(game: String, platform: Int, platformString: String) async {
    let mga = MobyGamesApi()
    await mga.buildGame(gameID: game, platformID: String(platform), platformString: platformString)
  }
  
  func deleteGame(games: [Game]) {
      games.forEach { game in
          // Delete the game from the context
          self.context.delete(game)
          
          // Update each CustomShelf's list of games
          shelves.forEach { shelf in
            if ((shelf.game_ids?.contains(Int(game.moby_id))) == true) {
              shelf.game_ids?.removeAll(where: {$0 == Int(game.moby_id)})
              }
          }
      }
      
      // Save the context and refresh all objects
      try? self.context.save()
      self.context.refreshAllObjects()
  }
  
  func getAllPlatforms() -> [Shelf] {
    var platforms: [Shelf] = []
    let request: NSFetchRequest<Game> = Game.fetchRequest()
    request.returnsObjectsAsFaults = false
    
    do {
      let games = itemController.fetchedObjects
      for game in games! {
        if let intValue = Int(game.platform_id!) {
          if (!platforms.contains { $0.platform_id == intValue} ) {
            platforms.append(Shelf(name: nil, platform_id: intValue, customShelf: nil))
          }
        }
      }
    }
    return [Shelf(name: "All", platform_id: 0, customShelf: nil)] + platforms
  }
  
  func getGameCountForPlatform(platform: Int) -> Int {
    if (platform == 0) {
      return games.count
    }
    return games.filter { game in
      return game.platform_id == String(platform)
    }.count
  }
    
  func getAllYears() -> [Int64] {
    let games = itemController.fetchedObjects
    var years: [Int64] = []
    for game in games! {
      if(!years.contains(where: { $0 == game.releaseYear })) {
        years.append(game.releaseYear)
      }
    }
    return years
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    do {
      try itemController.performFetch()
      games = itemController.fetchedObjects ?? []
      years = getAllYears()
    } catch {
      print("failed to fetch items")
    }
  }
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("WILL CHANGE")
  }
}

struct Shelf: Identifiable, Hashable {
  
  let id = UUID()
  let name: String?
  let platform_id: Int?
  let customShelf: CustomShelf?
 
    
  init(name: String?, platform_id: Int?, customShelf: CustomShelf?) {
    self.name = name
    self.platform_id = platform_id
    self.customShelf = customShelf
  }
}
