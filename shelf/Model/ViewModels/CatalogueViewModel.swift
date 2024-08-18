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
  @Published var searchText: String = ""
  @Published var loadingNewGame: Bool = false
  @Published var searchedGame: String = ""
  @Published var selectingPlatform: Bool = false
  
  func matchingGames(shelfModel: ShelfModel, year: Int? = nil) -> [Game] {
    return shelfModel.games.filter { game in
      
      if let year = year {
        return (Int(game.platform_id!)! == selection?.platform_id ?? 0 || selection?.platform_id == 0)
        && (game.title!.contains(searchText) || searchText.isEmpty) && game.releaseYear == year
      } else {
        
        if ((selection?.customShelf?.game_ids?.isEmpty) == false) {
          return (selection?.customShelf?.game_ids?.contains(Int(game.moby_id))) == true
        }
        
        return (Int(game.platform_id!)! == selection?.platform_id ?? 0 || selection?.platform_id == 0) && (game.title!.contains(searchText) || searchText.isEmpty)
      }
    }
  }
  
  func createGameSearchURL(scannedGameTitle: String) -> URL {
    let formattedTitle = scannedGameTitle.replacingOccurrences(of: "-", with: " ", options: NSString.CompareOptions.literal, range: nil).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "FAIL"
    return URL(string: "https://www.mobygames.com/search/?q=" + formattedTitle.unescaped)!
  }
}
