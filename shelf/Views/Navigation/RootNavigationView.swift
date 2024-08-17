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
  
  let gamecount: String
  @StateObject private var catalogueViewModel = CatalogueViewModel()
  
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
      CatalogueView(
          shelfModel: shelfModel,
          shelf: selection ?? Shelf(name: nil, platform_id: nil, customShelf: nil),
          catalogueModel: catalogueViewModel
      )
      .navigationTitle("All")
      .toolbar { // Ensure the .toolbar block is correct
          ToolbarItem(placement: .navigationBarTrailing) { // Ensure the correct placement is used
              CatalogueMenu(
                viewModel: catalogueViewModel
              )
          }
      }
    }
  }
}

