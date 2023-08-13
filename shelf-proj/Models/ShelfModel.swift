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
}
