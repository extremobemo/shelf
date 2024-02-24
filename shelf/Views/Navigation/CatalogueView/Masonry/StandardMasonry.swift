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
  
  @State private var loadingNewGame: Bool = false
  @Binding var showingScanner: Bool
  @Binding var sortByYear: Bool
  @Binding var selectedGames: [Game]
  @Binding var selectMode: Bool
  
  let matchingGames: [Game]
  var body: some View {
    
    Masonry(.vertical, lines: 5, horizontalSpacing: 8, verticalSpacing: 8) {
      ForEach(matchingGames) { game in
        if !selectMode {
          NavigationLink(destination: GameSheetView(game: game)) {
            CardView(imageName: game.cover_art).hoverEffect(.lift)
              .onAppear { loadingNewGame = false }
              .contextMenu {
                GameContextView(game: game, selectedGames: selectedGames)
              }
          }
        } else {
          CardView(imageName: game.cover_art).hoverEffect(.lift)
            .onAppear { loadingNewGame = false }
            .contextMenu {
              GameContextView(game: game, selectedGames: selectedGames)
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
  }
}
