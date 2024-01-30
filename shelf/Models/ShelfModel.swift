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
  @Published var games: [Game] = []
  @Published var years: [Int64] = []
  private let context: NSManagedObjectContext
  
  init(context: NSManagedObjectContext) {
    self.context = context
    let fetchRequest = NSFetchRequest<Game>(entityName: "Game")
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Game.title, ascending: true)]
    
    itemController = NSFetchedResultsController(fetchRequest: fetchRequest, 
                                                managedObjectContext: context,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
    
    super.init()
    itemController.delegate = self
    
    do {
      try itemController.performFetch()
      games = itemController.fetchedObjects ?? []
      years = getAllYears()
    } catch {
      print("failed to fetch items")
    }
  }
  
  func addGame(game: String, platform: Int, platformString: String) async {
    let mga = MobyGamesApi()
    await mga.buildGame(gameID: game, platformID: String(platform), platformString: platformString)
  }
  
  func deleteGame(game: Game) {
    self.context.delete(game)
    try? self.context.save()
    self.context.refreshAllObjects()
  }
  
  func getAllPlatforms() -> [Int] {
    var platforms: [Int] = []
    let request: NSFetchRequest<Game> = Game.fetchRequest()
    request.returnsObjectsAsFaults = false
    
    do {
      let games = itemController.fetchedObjects
      for game in games! {
        if let intValue = Int(game.platform_id!) {
          if (!platforms.contains(intValue)) {
            platforms.append(intValue)
          }
        }
      }
    }
    return platforms
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
