//
//  ShelfModel.swift
//  shelf-proj
//
//  Created by Bemo on 8/11/23.
//

import Foundation
import CoreData

class ShelfModel: ObservableObject {
    private (set) var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context        
    }
    
    func addGame() {
        let game = Game(context: context)
        game.title = "test game"
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
    
    func getColumns(count: Int) -> [[Game]]{
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
                    print(game)
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
        return columns
    }
}
