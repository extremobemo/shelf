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
  
  @State private var shelfName: String = ""
  @State private var presentAlert = false
  @State var showingScanner = false
  
  @State var showingSection1 = true
  @State var showingSection2 = true
  @State var selectingDestination = false
  
  @State var sortByYear = false
  @State var presentingMobySearch = false
  
  @State private var hasAppeared = false
  
  @State private var lastShelf: Shelf?
  
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
      
      List(selection: $catalogueViewModel.selection) {
        
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
      .onChange(of: catalogueViewModel.selection) {
        if lastShelf == nil {
          lastShelf = catalogueViewModel.selection
        }
      }
      .onAppear {
        if lastShelf == nil {
          if let firstPlatform = platforms.first {
            catalogueViewModel.selection = firstPlatform
          }
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
        shelf: catalogueViewModel.selection ?? Shelf(name: nil, platform_id: nil, customShelf: nil),
        catalogueModel: catalogueViewModel
      )
      .navigationTitle((catalogueViewModel.selection?.name ?? PlatformLookup.getPlaformName(platformID: catalogueViewModel.selection?.platform_id ?? 0)) ?? "0")
      
      .toolbar { // Ensure the .toolbar block is correct
        ToolbarItem(placement: .navigationBarTrailing) {
          CatalogueMenu(
            viewModel: catalogueViewModel
          )
        }
        ToolbarItem() {
          if catalogueViewModel.loadingNewGame {
            ProgressView()
          }
        }
      }
    }
  }
}

