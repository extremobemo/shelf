//
//  DrawerView.swift
//  shelf-proj
//
//  Created by Benjamin Morris on 9/16/23.
//

import Foundation
import SwiftUI
struct RootNavigationView: View {
  
  @ObservedObject private var shelfModel: ShelfModel
  private var platforms: [Shelf]
  private var shelves: [Shelf]
  
  let gamecount: String
  
  @State private var selectedGames: [Game] = []
  @State private var shelfName: String = ""
  @State private var presentAlert = false
  @State var showingScanner = false
  @State var selection: Shelf? = Shelf(name: "All", platform_id: 0, customShelf: nil)
  
  @State var showingSection1 = true
  @State var showingSection2 = true
  @State var selectingDestination = false
  
  @State var sortByYear = false
  @State var selectMode = false
  @State var presentingMobySearch = false

  
  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
    self.platforms = shelfModel.getAllPlatforms()
    self.shelves = shelfModel.getAllCustomShelves()
    self.gamecount = String(shelfModel.games.count)
  }
  
  var body: some View {
    NavigationSplitView() {
      
      List(selection: $selection) {
        
        Section() {
          if showingSection1 {
            ForEach(platforms, id: \.self) { plat in
              ConsoleListRow(platformID: plat.platform_id!, count: shelfModel.getGameCountForPlatform(platform: plat.platform_id!))
            }
          }
        } header: {
          Text("Catalogue")
        }
        
        Section() {
          if showingSection2 {
            ForEach(shelves, id: \.self) { shelf in
              CustomShelfListRow(count: shelf.customShelf?.game_ids?.count ?? 0, shelf: shelf)
            }
          }
        } header: {
          Text("Custom Shelves")
        }
        
      }
      .navigationTitle("Shelf").toolbar {
        ToolbarItem() {
          HomeMenu(shelfModel: shelfModel, presentAlert: $presentAlert, shelfName: $shelfName)
        }
      }.listStyle(.sidebar)
    }
  detail: {
    CatalogueView(shelfModel: shelfModel, shelf: selection ?? Shelf(name: nil, platform_id: nil, customShelf: nil),
                  showingScanner: $showingScanner, selectMode: $selectMode, sortByYear: $sortByYear,
                  selectedGames: $selectedGames, presentingMobySearch: $presentingMobySearch).navigationTitle((PlatformLookup.getPlaformName(platformID:
                                                                                                  selection?.platform_id ?? 0) ?? selection?.customShelf?.name) ?? "All").toolbar {
                    ToolbarItem() {
                      CatalogueMenu(presentingMobySearch: $presentingMobySearch,selectMode: $selectMode,
                                    showingScanner: $showingScanner, sortByYear: $sortByYear, selectingDestination: $selectingDestination)
                    }
                  }
  }.sheet(isPresented: $selectingDestination) {
    NavigationView {
      VStack {
        List() {
          ForEach(shelves, id: \.self) { shelf in
            Button(action: {
              shelfModel.addGamesToShelf(shelf: shelf, games: selectedGames)
              selectingDestination = false
              selectMode = false
            }) {
              HStack {
                Text(shelf.name!)
                Spacer()
                Image(systemName: "plus")
              }
            }
          }
        }
      }
      .navigationTitle("Add to...")
      .navigationBarItems(trailing: Button("Cancel",
                                           action: {}))
    }
  }
  }
  
}

