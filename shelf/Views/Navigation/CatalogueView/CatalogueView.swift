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
  
  @State private var presentingGameInfoSheet = false
  @State private var shouldShowDisclaimer = true
  @State private var selectedGame: Game? = nil
  
  private var mga = MobyGamesApi()
  private var shelf: Shelf
  private var matchingGames: [Game]
  let plu = PlatformLookup()
  
  init(shelfModel: ShelfModel, shelf: Shelf, catalogueModel: CatalogueViewModel) {
    
    _shelfModel = StateObject(wrappedValue: shelfModel)

    self.shelf = shelf
    self.catalogueModel = catalogueModel
    self.matchingGames = catalogueModel.matchingGames(shelfModel: shelfModel)
  }
  
  var body: some View {
    NavigationStack {
      ScrollView(.vertical) {
        Spacer()
        
        if shelfModel.games.count == 0 {
          VStack {
            Spacer()
            Text("Add games to view collection").foregroundStyle(.gray)
            Spacer()
          }
        }
        
        if catalogueModel.sortByYear {
          ForEach(shelfModel.years.sorted(), id: \.self) { year in
            let yearMatchingGames = catalogueModel.matchingGames(shelfModel: shelfModel, year: Int(year)).filter { game in
              return game.releaseYear == year
            }
            
            if !yearMatchingGames.isEmpty {
              
              Text(String(year))
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
              
              StandardMasonry(shelfModel: shelfModel, catalogueDataModel: catalogueModel, games: yearMatchingGames)
              Spacer().frame(height: 48)
            }
          }.searchable(text: $catalogueModel.searchText)
          
        } else {
          StandardMasonry(shelfModel: shelfModel, catalogueDataModel: catalogueModel, games: matchingGames)
           .searchable(text: $catalogueModel.searchText)
        }
      }
    }
    .onChange(of: selectedGame, initial: false) { _, _ in
      if selectedGame != nil { presentingGameInfoSheet = true }
    }

    .padding(EdgeInsets(top: 0, leading: 16.0, bottom: 0, trailing: 16.0))
    
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
          
          WebView(url: catalogueModel.createGameSearchURL(scannedGameTitle: dataScannerModel.scannedGameTitle),
                  loadingNewGame: $catalogueModel.loadingNewGame,
                  shelfModel: shelfModel,
                  catalogueModel: catalogueModel,
                  dataScannerModel: dataScannerModel)
          
          .alert(isPresented: $shouldShowDisclaimer) {
            Alert(title: Text("Redirecting to MobyGames"), message: Text("You are being redirected to an external website that is not affiliated with Shelf. Shelf is not responsible for the content or experience on the site."), dismissButton: .default(Text("Got it!")) )
          }
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
          
          WebView(url: catalogueModel.createGameSearchURL(scannedGameTitle: ""),
                  loadingNewGame: $catalogueModel.loadingNewGame,
                  shelfModel: shelfModel,
                  catalogueModel: catalogueModel,
                  dataScannerModel: dataScannerModel)
          
          .alert(isPresented: $shouldShowDisclaimer) {
            Alert(title: Text("Redirecting to MobyGames"), message: Text("You are being redirected to an external website that is not affiliated with Shelf. Shelf is not responsible for the content or experience on the site."), dismissButton: .default(Text("Got it!")) )
          }
        }
      }
    }
    
    .sheet(isPresented: $catalogueModel.selectingPlatform) {
      PlatformSelector(shelfModel: shelfModel, searchedGame: $catalogueModel.searchedGame, selectingPlatform: $catalogueModel.selectingPlatform)
    }
    
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
        .navigationBarItems(trailing: Button("Cancel", action: {
          catalogueModel.selectingDestination = false
          catalogueModel.selectMode = false
        }))
      }
    }
  }
}
