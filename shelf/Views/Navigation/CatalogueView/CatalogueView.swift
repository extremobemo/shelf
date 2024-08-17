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
  
  @ObservedObject var catalogueModel: CatalogueViewModel

  @StateObject var shelfModel: ShelfModel
  @StateObject var dataScannerModel = DataScannerViewModel()

  @State private var searchText: String = ""
  @State private var loadingNewGame: Bool = false
  @State var searchedGame: String = ""
  @State private var presentingGameInfoSheet = false
  @State var selectingPlatform: Bool = false
  @State private var shouldShowDisclaimer = true
  @State private var selectedGame: Game? = nil
  
  private var mga = MobyGamesApi()
  private var shelf: Shelf
  let plu = PlatformLookup()

  init(shelfModel: ShelfModel, shelf: Shelf, catalogueModel: CatalogueViewModel) {
    
    self.shelf = shelf
  
    _shelfModel = StateObject(wrappedValue: shelfModel)
    self.catalogueModel = catalogueModel
  }
  
  var body: some View {
    NavigationStack {
      ScrollView(.vertical) {
        Spacer()
        
        let matchingGames = catalogueModel.matchingGames(shelfModel: shelfModel, searchText: searchText)
        
        if shelfModel.games.count == 0 {
          VStack {
            Spacer()
            Text("Add games to view collection").foregroundStyle(.gray)
            Spacer()
          }
        }
        
        if catalogueModel.sortByYear {
          ForEach(shelfModel.years.sorted(), id: \.self) { year in
            let yearMatchingGames = matchingGames.filter { game in
              return game.releaseYear == year
            }

            if !yearMatchingGames.isEmpty {

              Text(String(year))
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

//              StandardMasonry(loadingNewGame: $loadingNewGame, showingScanner: $catalogueModel.showingScanner, sortByYear: $catalogueModel.sortByYear,
//                              selectedGames: $catalogueModel.selectedGames, selectMode: $catalogueModel.selectMode,
//                              matchingGames: yearMatchingGames, shelfModel: shelfModel)
//              Spacer().frame(height: 48)
            }
          }.searchable(text: $searchText)
        } else {
          StandardMasonry(shelfModel: shelfModel, loadingNewGame: $loadingNewGame, showingScanner: $catalogueModel.showingScanner,sortByYear: $catalogueModel.sortByYear,
                          selectedGames: $catalogueModel.selectedGames, selectMode: $catalogueModel.selectMode,
                          matchingGames: matchingGames).searchable(text: $searchText)
        }
      }
    }
    .onChange(of: selectedGame, initial: false) { _, _ in
      if selectedGame != nil { presentingGameInfoSheet = true }
    }
    //    .onChange(of: $selectedGames, initial: true) { _, _ in
    //      // selectedGames = []
    //    }
    .padding(EdgeInsets(top: 0, leading: 16.0, bottom: 0, trailing: 16.0))
    //    .sheet(isPresented: $presentingGameInfoSheet, onDismiss: {
    //      selectedGame = nil
    //    }) { GameSheetView(game: selectedGame!) }.toolbar {
    //      ToolbarItem() {
    //        if loadingNewGame {
    //          ProgressView()
    //        }
    //      }
    //    }
    
        .fullScreenCover(isPresented: $catalogueModel.presentingMobySearch) {
          if dataScannerModel.scannedGamePlatform != nil {
            VStack {
              HStack {
                Spacer()
                Button(action: {
                  catalogueModel.presentingMobySearch = false
                }) {
                  Text("Close").frame(height: 12).padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 8))
                }
              }
              .frame(height: 16)
              .shadow(radius: 0)
              .shadow(radius: 0)
              
              
    
              WebView(url: createGameSearchURL(scannedGameTitle: dataScannerModel.scannedGameTitle), loadingNewGame: $loadingNewGame,
                      shelfModel: shelfModel, platform_name: $dataScannerModel.scannedGamePlatform, isPresented: $catalogueModel.presentingMobySearch, selectingPlatform: $selectingPlatform, presentingMobySearch: $catalogueModel.presentingMobySearch,
                      searchedGame: $searchedGame)
              
//              .alert(isPresented: $shouldShowDisclaimer) {
//                Alert(title: Text("Redirecting to MobyGames"), message: Text("You are being redirected to an external website that is not affiliated with Shelf. Shelf is not responsible for the content or experience on the site."), dismissButton: .default(Text("Got it!")) )
//              }
            }
          } else {
            VStack {
              HStack {
                Spacer()
                Button(action: {
                  catalogueModel.presentingMobySearch = false
                }) {
                  Text("Close").frame(height: 12).padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 8))
                }
              }
              .frame(height: 16)
              .shadow(radius: 0)
              
              WebView(url: createGameSearchURL(scannedGameTitle: ""), loadingNewGame: $loadingNewGame,
                      shelfModel: shelfModel, platform_name: $dataScannerModel.scannedGamePlatform, isPresented: $catalogueModel.presentingMobySearch, selectingPlatform: $selectingPlatform, presentingMobySearch: $catalogueModel.presentingMobySearch,
                      searchedGame: $searchedGame)
    
//              WebView(url: createGameSearchURL(scannedGameTitle: ""), loadingNewGame: $loadingNewGame,
//                      shelfModel: shelfModel, platform_name: dataScannerModel.scannedGamePlatform, isPresented: $catalogueModel.presentingMobySearch, selectingPlatform: $catalogueModel.selectingPlatform, presentingMobySearch: $catalogueModel.presentingMobySearch,
//                      searchedGame: $catalogueModel.searchedGame)
//              .alert(isPresented: $shouldShowDisclaimer) {
//                Alert(title: Text("Redirecting to MobyGames"), message: Text("You are being redirected to an external website that is not affiliated with Shelf. Shelf is not responsible for the content or experience on the site."), dismissButton: .default(Text("Got it!")) )
//              }
            }
          }
        }
    
//        .sheet(isPresented: $catalogueModel.selectingPlatform) {
//          PlatformSelector(shelfModel: shelfModel, searchedGame: $catalogueModel.searchedGame, selectingPlatform: $catalogueModel.selectingPlatform)
//        }
//    
//        .sheet(isPresented: $catalogueModel.showingScanner) {
//          DataScanner(shelfModel: shelfModel, game: $dataScannerModel.scannedGameTitle, platform_name: $dataScannerModel.scannedGamePlatform)
//        }.onChange(of: dataScannerModel.scannedGameTitle, initial: false) { new, old in
//          catalogueModel.presentingMobySearch = true
//        }
//        .hoverEffect(.automatic)
    .sheet(isPresented: $catalogueModel.showingScanner) {
      DataScanner(shelfModel: shelfModel, viewModel: dataScannerModel)
      
    }.onChange(of: dataScannerModel.scannedGameTitle, initial: false) { new, old in
      catalogueModel.presentingMobySearch = true
    }
    
    .sheet(isPresented: $catalogueModel.selectingDestination) {
      NavigationView {
        VStack {
          List() {
            ForEach(shelfModel.getAllCustomShelves(), id: \.self) { shelf in
              Button(action: {
                shelfModel.addGamesToShelf(shelf: shelf, games: catalogueModel.selectedGames)
                catalogueModel.selectingDestination = false
                catalogueModel.selectMode = false
              }) {
                HStack {
                  Text(shelf.name!).foregroundStyle(.white)
                }
              }
            }
          }
        }
        .navigationTitle("Add to...")
        .navigationBarItems(trailing: Button("Cancel", action: { }))
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
  
  @ObservedObject var shelfModel: ShelfModel
  
  var body: some View {
    Button {
      shelfModel.deleteGame(games: selectedGames)
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
