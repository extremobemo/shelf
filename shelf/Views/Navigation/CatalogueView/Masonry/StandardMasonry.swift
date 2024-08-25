//
//  StandardMasonry.swift
//  shelf
//
//  Created by Bemo on 2/22/24.
//

import Foundation
import SwiftUI
import SwiftUIMasonry

struct StandardMasonry: View {
  
  private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
  
  @ObservedObject var shelfModel: ShelfModel
  @ObservedObject var catalogueDataModel: CatalogueViewModel
  
  var games: [Game]
  
  var body: some View {
    
    Masonry(.vertical, lines: getCarouselHeight(), horizontalSpacing: 8, verticalSpacing: 8) {
      ForEach(games, id: \.self) { (game: Game) in
        let cover_art = game.cover_art?.first
        if !catalogueDataModel.selectMode {
          NavigationLink(destination: GameSheetView(game: game)) {
            CardView(imageName: cover_art, gameTitle: game.title ?? "Title not found").hoverEffect(.lift)
              .onAppear {
                catalogueDataModel.loadingNewGame = false
              }
              .contextMenu {
                GameContextView(game: game, selectedGames: catalogueDataModel.selectedGames, shelfModel: shelfModel)
              }
          }
        } else {
          CardView(imageName: cover_art, gameTitle: game.title ?? "Title not found").hoverEffect(.lift)
            .onAppear { catalogueDataModel.loadingNewGame = false }
            .contextMenu {
              GameContextView(game: game, selectedGames: catalogueDataModel.selectedGames, shelfModel: shelfModel)
            }
            .onTapGesture{
              if !catalogueDataModel.selectedGames.contains(game) {
                catalogueDataModel.selectedGames.append(game)
              } else {
                catalogueDataModel.selectedGames.removeAll(where: { $0 == game })
                if catalogueDataModel.selectedGames.count == 0 {
                  catalogueDataModel.selectMode = false
                }
              }
            }
            .opacity(catalogueDataModel.selectedGames.contains(where: { $0 == game }) ? 0.4 : 1.0)
            .overlay(alignment: .bottomTrailing) {
              if catalogueDataModel.selectedGames.contains(where: { $0 == game }) {
                Circle()
                  .stroke(.white, lineWidth: 4)
                  .fill(.blue)
                  .frame(width: 16, height: 16)
                  .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 8))
                
              } else {
                Circle()
                  .stroke(.white, lineWidth: 2)
                  .frame(width: 16, height: 16)
                  .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 8))
              }
            }
        }
      }
    }.masonryPlacementMode(.order)
      .onChange(of: catalogueDataModel.selectMode) {
        catalogueDataModel.selectedGames = []
      }
  }
  
  private func getCarouselHeight() -> Int {
    if idiom == .pad {
      return 4
    } else {
      return 3
    }
  }
}
