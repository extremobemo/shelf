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
  
  @Binding var loadingNewGame: Bool
  @Binding var showingScanner: Bool
  @Binding var sortByYear: Bool
  @Binding var selectedGames: [Game]
  @Binding var selectMode: Bool
  
  let matchingGames: [Game]
  
  var body: some View {
    
    Masonry(.vertical, lines: getCarouselHeight(), horizontalSpacing: 8, verticalSpacing: 8) {
      ForEach(matchingGames) { game in
        let cover_art = game.cover_art?.first
        if !selectMode {
          NavigationLink(destination: GameSheetView(game: game)) {
            
           
              CardView(imageName: cover_art).hoverEffect(.lift)
                .onAppear { loadingNewGame = false }
                .contextMenu {
                  GameContextView(game: game, selectedGames: selectedGames, shelfModel: shelfModel)
              }
            
          }
        } else {
          CardView(imageName: cover_art).hoverEffect(.lift)
            .onAppear { loadingNewGame = false }
            .contextMenu {
              GameContextView(game: game, selectedGames: selectedGames, shelfModel: shelfModel)
            }
            .onTapGesture{
              if !selectedGames.contains(game) {
                selectedGames.append(game)
              } else {
                selectedGames.removeAll(where: { $0 == game })
                if selectedGames.count == 0 {
                  selectMode = false
                }
              }
            }
            .opacity(selectedGames.contains(where: { $0 == game }) ? 0.4 : 1.0)
            .overlay(alignment: .bottomTrailing) {
              if selectedGames.contains(where: { $0 == game }) {
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
      .onChange(of: selectMode) {
        selectedGames = []
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
