//
//  CatalogueViewModel.swift
//  shelf
//
//  Created by Bemo on 8/17/24.
//

import SwiftUI

class CatalogueViewModel: ObservableObject {
  @Published var showingScanner: Bool = false
  @Published var selection: Shelf? = Shelf(name: "All", platform_id: 0, customShelf: nil)
  @Published var selectedGames: [Game] = []
  @Published var sortByYear = false
  @Published var selectMode = false
  @Published var presentingMobySearch = false
  @Published var selectingDestination: Bool = false
  
  func matchingGames(shelfModel: ShelfModel,
                     searchText: String) -> [Game] {
    
    return shelfModel.games.filter { game in
      if selection?.platform_id != nil {
        return (Int(game.platform_id!)! == selection?.platform_id ?? 0 || selection?.platform_id == 0)
        && (game.title!.contains(searchText) || searchText.isEmpty)
        
      } else {
        if let games = selection?.customShelf?.game_ids {
          if searchText == "", games.contains(where: { $0 == game.moby_id }) { return true }
            return games.contains(where: {
              $0 == game.moby_id &&
              game.title!.contains(searchText)
            })
        } else {
          return false
        }
      }
    }
  }
}
