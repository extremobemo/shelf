//
//  CatalogueView.swift
//  shelf-proj
//
//  Created by Benjamin Morris on 9/16/23.
//

import Foundation
import SwiftUI
import AVKit
import CoreData

struct CatalogueView: View {
  
  @StateObject var shelfModel: ShelfModel
  private var shelf: Shelf
  
  @State private var searchText: String = ""
  @State private var scannedGameTitle: String = ""
  @State private var scannedGamePlatform: String?
  @State private var presentingGameInfoSheet = false
  @State private var loadingNewGame: Bool = false
  @State var selectingPlatform: Bool = false
  @State var searchedGame: String = ""
  
  @Binding var showingScanner: Bool
  @Binding var sortByYear: Bool
  @Binding var selectedGames: [Game]
  @Binding var selectMode: Bool
  @Binding var presentingMobySearch: Bool
  @State private var shouldShowDisclaimer = true
  
  private var mga = MobyGamesApi()
  
  init(shelfModel: ShelfModel, shelf: Shelf, showingScanner: Binding<Bool>,
       selectMode: Binding<Bool>, sortByYear: Binding<Bool>, selectedGames: Binding<[Game]>,
       presentingMobySearch: Binding<Bool>) {
    
    self._showingScanner = showingScanner
    self._selectMode = selectMode
    self._presentingMobySearch = presentingMobySearch
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
        
        if shelfModel.games.count == 0 {
          VStack {
            Spacer()
            Text("Add games to view collection").foregroundStyle(.gray)
            Spacer()
          }
        }
        
        if sortByYear {
          
          ForEach(shelfModel.years.sorted(), id: \.self) { year in
            let yearMatchingGames = matchingGames.filter { game in
              return game.releaseYear == year
            }
            
            if !yearMatchingGames.isEmpty {
              
              Text(String(year))
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
              
              StandardMasonry(loadingNewGame: $loadingNewGame, showingScanner: $showingScanner, sortByYear: $sortByYear,
                              selectedGames: $selectedGames, selectMode: $selectMode,
                              matchingGames: yearMatchingGames)
              Spacer().frame(height: 48)
            }
          }.searchable(text: $searchText)
        } else {
          StandardMasonry(loadingNewGame: $loadingNewGame, showingScanner: $showingScanner,sortByYear: $sortByYear,
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
    
    .fullScreenCover(isPresented: $presentingMobySearch) {
      if scannedGamePlatform != nil {
        VStack {
          HStack {
            Spacer()
            Button(action: {
              presentingMobySearch = false
            }) {
              Text("Close").frame(height: 12).padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 8))
            }
          }
          .frame(height: 16)
          .shadow(radius: 0)
          
          WebView(url: createGameSearchURL(scannedGameTitle: scannedGameTitle), loadingNewGame: $loadingNewGame,
                  shelfModel: shelfModel, platform_name: scannedGamePlatform, isPresented: $presentingMobySearch, selectingPlatform: $selectingPlatform, presentingMobySearch: $presentingMobySearch,
                  searchedGame: $searchedGame)
          .alert(isPresented: $shouldShowDisclaimer) {
            Alert(title: Text("Redirecting to MobyGames"), message: Text("You are being redirected to an external website that is not affiliated with Shelf. Shelf is not responsible for the content or experience on the site."), dismissButton: .default(Text("Got it!")) )
          }
        }
      } else {
        VStack {
          HStack {
            Spacer()
            Button(action: {
              presentingMobySearch = false
            }) {
              Text("Close").frame(height: 12).padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 8))
            }
          }
          .frame(height: 16)
          .shadow(radius: 0)
          
          WebView(url: createGameSearchURL(scannedGameTitle: ""), loadingNewGame: $loadingNewGame,
                  shelfModel: shelfModel, platform_name: scannedGamePlatform, isPresented: $presentingMobySearch, selectingPlatform: $selectingPlatform, presentingMobySearch: $presentingMobySearch,
                  searchedGame: $searchedGame)
          .alert(isPresented: $shouldShowDisclaimer) {
            Alert(title: Text("Redirecting to MobyGames"), message: Text("You are being redirected to an external website that is not affiliated with Shelf. Shelf is not responsible for the content or experience on the site."), dismissButton: .default(Text("Got it!")) )
          }
        }
      }
    }
    
    .sheet(isPresented: $selectingPlatform) {
      PlatformSelector(shelfModel: shelfModel, searchedGame: $searchedGame, selectingPlatform: $selectingPlatform)
    }
    
    .sheet(isPresented: $showingScanner) {
      DataScanner(shelfModel: shelfModel, game: $scannedGameTitle, platform_name: $scannedGamePlatform)
    }.onChange(of: scannedGameTitle, initial: false) { new, old in
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
        if searchText == "" { return true }
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

func createGameSearchURL(scannedGameTitle: String) -> URL {
  let formattedTitle = scannedGameTitle.replacingOccurrences(of: "-", with: " ", options: NSString.CompareOptions.literal, range: nil).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "FAIL"
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
