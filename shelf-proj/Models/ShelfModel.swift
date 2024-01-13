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

class ShelfModel: ObservableObject {
  private (set) var context: NSManagedObjectContext
  @FetchRequest(
    sortDescriptors: [],
    animation: .default)
  // Init this based on number of desired columns
  private var games: FetchedResults<Game>
  @Published var columns: [[Game]] = [[],[],[],[],[]]

  init(context: NSManagedObjectContext) {
    self.context = context
    getColumns(count: 5)
  }

    func addGame(game: String, platform: Int, platformString: String) async {
    let mga = MobyGamesApi()
    await mga.buildGame(gameID: game, platformID: String(platform), platformString: platformString)
    self.context.refreshAllObjects()
  }

  func getGameCount() -> Int {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Game")

    request.returnsObjectsAsFaults = false
    var game_count = 0
    do {
      let games = try self.context.fetch(request)
      game_count = games.count
    } catch {
      print("Error fetching games: \(error)")
    }
    return game_count
  }
    
    func getAllPlatforms() -> [String] {
        var platforms: [String] = []
        let request: NSFetchRequest<Game> = Game.fetchRequest()

        request.returnsObjectsAsFaults = false
        // var game_count = 0
        do {
          let games = try self.context.fetch(request)
            for game in games {
                if let intValue = Int(game.platform_id!) {
                    if (!platforms.contains(PlatformLookup.getPlaformName(platformID: intValue))) {
                        
                        
                        platforms.append(PlatformLookup.getPlaformName(platformID: intValue))
                        
                        // Access properties of the Game entity
                        // You can work with 'game' just like any other Swift object
                    }
                }
            }
        } catch {
          print("Error fetching games: \(error)")
        }
        return platforms
    }
    
func getColumns(count: Int) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Game")

    var columns: [[Game]] = [[]]

    // Initialize the array with 'X' empty arrays of Game objects
    for _ in 0...count - 1 {
      columns.append(Array(repeating: Game(), count: 0))
    }

    request.returnsObjectsAsFaults = false
    var game_count = 0
    do {
      let games = try self.context.fetch(request)
      games.forEach { game in
        if let game = game as? Game {
          columns[game_count].append(game)

          game_count += 1

          if game_count == count {
            game_count = 0
          }
        }
      }
    } catch {
      print("Error fetching games: \(error)")
    }
    DispatchQueue.main.async {
      self.columns = columns
    }
    //print(columns)
  }

  func updateGameDesc(gameID: Int64, desc: String) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Game")
    var games: [Game] = []
    request.returnsObjectsAsFaults = false
    do {
      games = try self.context.fetch(request) as! [Game]
    } catch {}

    let game = games.first(where: { $0.moby_id == gameID })
    game?.desc = desc

    do {
      try context.save()
    } catch {}
  }
}
