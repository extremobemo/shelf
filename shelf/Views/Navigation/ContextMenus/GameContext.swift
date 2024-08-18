//
//  GameContext.swift
//  shelf
//
//  Created by Bemo on 8/17/24.
//

import SwiftUI

struct GameContextView: View {
  var game: Game
  var selectedGames: [Game]
  
  @ObservedObject var shelfModel: ShelfModel
  
  var body: some View {
    Button {
      shelfModel.deleteGame(games: selectedGames.count > 1 ? selectedGames : [game])
    } label: {
      Label("Delete Game", systemImage: "trash")
    }
  }
}
