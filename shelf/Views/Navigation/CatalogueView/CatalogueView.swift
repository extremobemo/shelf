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
  private var shelf: Shelf
  
  @Binding var showingScanner: Bool
  @Binding var sortByYear: Bool
  @Binding var selectedGames: [Game]
  @Binding var selectMode: Bool
  
  private var mga = MobyGamesApi()
  let container = CKContainer(identifier: "iCloud.icloud.extremobemo.shelf-proj")
  
  init(shelfModel: ShelfModel,
       shelf: Shelf,
       showingScanner: Binding<Bool>,
       selectMode: Binding<Bool>,
       sortByYear: Binding<Bool>,
       selectedGames: Binding<[Game]>) {
    
    self._showingScanner = showingScanner
    self._selectMode = selectMode
    self.shelf = shelf
    
    self._showingScanner = showingScanner
    self._sortByYear = sortByYear
    self._selectedGames = selectedGames
    
    _shelfModel = StateObject(wrappedValue: shelfModel)
  }
  
  @State private var selectedGame: Game? = nil
  
  let plu = PlatformLookup()
  
  var body: some View {
    NavigationStack {
      ScrollView(.vertical) {
        
        Spacer()
        
        let matchingGames = matchingGames(shelfModel: shelfModel, customShelf: shelf.customShelf,
                                          searchText: searchText, platform_id: shelf.platform_id)
        
        if sortByYear {
          
          ForEach(shelfModel.years.sorted(), id: \.self) { year in
            let yearMatchingGames = matchingGames.filter { game in
              return game.releaseYear == year
            }
            
            if !yearMatchingGames.isEmpty {
              
              Text(String(year))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
              
              StandardMasonry(showingScanner: $showingScanner,sortByYear: $sortByYear,
                              selectedGames: $selectedGames, selectMode: $selectMode,
                              matchingGames: yearMatchingGames)
            }
          }.searchable(text: $searchText)
        } else {
          StandardMasonry(showingScanner: $showingScanner,sortByYear: $sortByYear,
                          selectedGames: $selectedGames, selectMode: $selectMode,
                          matchingGames: matchingGames).searchable(text: $searchText)
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
      WebView(url: createGameSearchURL(scannedGameTitle: scannedGameTitle), loadingNewGame: $loadingNewGame,
              shelfModel: shelfModel, platform_name: scannedGamePlatform, isPresented: $presentingMobySearch)
    }
    .sheet(isPresented: $showingScanner) {
      DataScanner(shelfModel: shelfModel, game: $scannedGameTitle, platform_name: $scannedGamePlatform)
    }.onChange(of: scannedGameTitle, initial: false) { _, _ in
      presentingMobySearch = true
    }
    .hoverEffect(.automatic)
  }
  
}

func matchingGames(shelfModel: ShelfModel, customShelf: CustomShelf?,
                   searchText: String, platform_id: Int?) -> [Game] {
  return shelfModel.games.filter { game in
    if platform_id != nil {
      return (Int(game.platform_id!)! == platform_id ?? 0 || platform_id == 0)
      && (game.title!.contains(searchText) || searchText.isEmpty)
    } else {
      if let games = customShelf?.game_ids {
        if games.contains(where: { $0 == game.moby_id }) {
          return true
        } else { return false }
      } else {
        return false
      }
    }
  }
}

func createGameSearchURL(scannedGameTitle: String) -> URL {
  let formattedTitle = scannedGameTitle.replacingOccurrences(of: "-", with: " ", options: NSString.CompareOptions.literal, range: nil).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "FAIL"
  
  // This might crash
  return URL(string: "https://www.mobygames.com/search/?q=" + formattedTitle.unescaped)!
}


struct GameContextView: View {
  var game: Game
  var selectedGames: [Game]
  
  var body: some View {
    Button {
      selectedGames.forEach { game in
        CoreDataManager.shared.persistentStoreContainer.viewContext.delete(game)
      }
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
