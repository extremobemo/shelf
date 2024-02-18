//
//  CatalogueView.swift
//  shelf-proj
//
//  Created by Benjamin Morris on 9/16/23.
//

import Foundation
import SwiftUI
import VisionKit
import AVKit
import CloudKit
import SwiftUIMasonry
import CoreData

struct CatalogueView: View {
  
  @StateObject var shelfModel: ShelfModel
  
  // Toolbar filter string
  @State private var searchText: String = ""
  
  // DataScanner will populate these fields.
  @State private var scannedGameTitle: String = ""
  @State private var scannedGamePlatform: String?
  
  // Control Popovers
  @State private var presentingGameInfoSheet = false
  
  @State var presentingMobySearch: Bool = false
  
  // Display progress view
  @State private var loadingNewGame: Bool = false
  
  // We use this to decide which cardViews to show
  private var platformFilterID: Int?
  @Binding var showingScanner: Bool
  @Binding var sortByYear: Bool

  @Binding var selectMode: Bool
  @State var selectedGames: [Game] = []
      
  private var mga = MobyGamesApi()
  let container = CKContainer(identifier: "iCloud.icloud.extremobemo.shelf-proj")
  
  init(shelfModel: ShelfModel, 
       platformFilterID: Int?,
       showingScanner: Binding<Bool>,
       selectMode: Binding<Bool>,
       sortByYear: Binding<Bool>) {
    self._showingScanner = showingScanner
    self._selectMode = selectMode
    self.platformFilterID = platformFilterID
   
    self._showingScanner = showingScanner
    self._sortByYear = sortByYear
    self.platformFilterID = platformFilterID
    
    _shelfModel = StateObject(wrappedValue: shelfModel)
  }
  
  @State private var selectedGame: Game? = nil
  
  let plu = PlatformLookup()
  
  var body: some View {
    NavigationStack {
      ScrollView(.vertical) {
        
        Spacer()
        
        let matchingGames = shelfModel.games.filter { game in
          return (Int(game.platform_id!) == self.platformFilterID ?? 0 || self.platformFilterID == 0)
          && (game.title!.contains(searchText) || searchText.isEmpty)
        }
        if sortByYear {
          
          ForEach(shelfModel.years.sorted(), id: \.self) { year in
            let yearMatchingGames = matchingGames.filter { game in
              return game.releaseYear == year
            }
            if !yearMatchingGames.isEmpty {
              if sortByYear {
                Text(String(year))
                  .font(.title2)
                  .fontWeight(.semibold)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
              
              Masonry(.vertical, lines: 3, horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(yearMatchingGames) { game in
                if !selectMode {
                  NavigationLink(destination: GameSheetView(game: game)) {
                    CardView(imageName: game.cover_art).hoverEffect(.lift)
                      .onAppear { loadingNewGame = false }
                      .contextMenu {
                        GameContextView(game: game)
                      }
                  }
                } else {
                  CardView(imageName: game.cover_art).hoverEffect(.lift)
                    .onAppear { loadingNewGame = false }
                    .contextMenu {
                      GameContextView(game: game)
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
          }.searchable(text: $searchText)
        } else {
          Masonry(.vertical, lines: 3, horizontalSpacing: 8, verticalSpacing: 8) {
            ForEach(matchingGames) { game in
            if !selectMode {
              NavigationLink(destination: GameSheetView(game: game)) {
                CardView(imageName: game.cover_art).hoverEffect(.lift)
                  .onAppear { loadingNewGame = false }
                  .contextMenu {
                    GameContextView(game: game)
                  }
              }
            } else {
              CardView(imageName: game.cover_art).hoverEffect(.lift)
                .onAppear { loadingNewGame = false }
                .contextMenu {
                  GameContextView(game: game)
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
            .searchable(text: $searchText)
        }
      }
    }
    .onChange(of: selectedGame, initial: false) { _, _ in
      if selectedGame != nil { presentingGameInfoSheet = true }
    }
    .padding(EdgeInsets(top: 0, leading: 16.0, bottom: 0, trailing: 16.0))
    .sheet(isPresented: $presentingGameInfoSheet, onDismiss: {
      selectedGame = nil
    }) { GameSheetView(game: selectedGame!) }.toolbar {
      ToolbarItem() {
        if loadingNewGame {
          ProgressView()
        }
      }
    }
    .sheet(isPresented: $presentingMobySearch) {
      WebView(url: createGameSearchURL(scannedGameTitle: scannedGameTitle),
              loadingNewGame: $loadingNewGame,
              shelfModel: shelfModel,
              platform_name: scannedGamePlatform,
              isPresented: $presentingMobySearch)
    }
    .sheet(isPresented: $showingScanner) {
      // Data scanner will write back the scanned title and Platform
      // into `scannedGameTitle` & `scannedGamePlatform`
      DataScanner(shelfModel: shelfModel,
                  game: $scannedGameTitle,
                  platform_name: $scannedGamePlatform)
    }.onChange(of: scannedGameTitle, initial: false) { _, _ in
      presentingMobySearch = true
    }
    .hoverEffect(.automatic)
  }
  
}
  
func createGameSearchURL(scannedGameTitle: String) -> URL {
  let formattedTitle = scannedGameTitle.replacingOccurrences(of: "-", with: " ", options: NSString.CompareOptions.literal, range: nil).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "FAIL"
  
  // This might crash
  return URL(string: "https://www.mobygames.com/search/?q=" + formattedTitle.unescaped)!
}


struct GameContextView: View {
  var game: Game
  
  var body: some View {
    Button {
      CoreDataManager.shared.persistentStoreContainer.viewContext.delete(game)
      try? CoreDataManager.shared.persistentStoreContainer.viewContext.save()
      CoreDataManager.shared.persistentStoreContainer.viewContext.refreshAllObjects()
    } label: {
      Label("Delete Game", systemImage: "trash")
    }
  }
}

struct BlurView: UIViewRepresentable {
  var style: UIBlurEffect.Style = .systemUltraThinMaterial
  func makeUIView(context: Context) -> UIVisualEffectView {
    return UIVisualEffectView(effect: UIBlurEffect(style: style))
  }
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: style)
  }
}
