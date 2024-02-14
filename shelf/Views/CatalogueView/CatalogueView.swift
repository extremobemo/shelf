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
  private var platformFilterID: String?
  @Binding var showingScanner: Bool
  let navTitle: String
    
  private var mga = MobyGamesApi()
  let container = CKContainer(identifier: "iCloud.icloud.extremobemo.shelf-proj")
  
  init(shelfModel: ShelfModel, platformFilterID: Int?, showingScanner: Binding<Bool>) {
    if platformFilterID != nil{
      self.navTitle = PlatformLookup.getPlaformName(platformID: platformFilterID ?? 0) ?? "FAIL"
      self.platformFilterID =  PlatformLookup.getPlaformName(platformID: platformFilterID!)

    } else {
      self.navTitle = "Catalogue"
    }
    self._showingScanner = showingScanner
   
    _shelfModel = StateObject(wrappedValue: shelfModel)
  }
  
  @State private var selectedGame: Game? = nil
  
  let plu = PlatformLookup()
  
  var body: some View {
    NavigationStack {
      ScrollView(.vertical) {
        Masonry(.vertical, lines: 5, horizontalSpacing: 12, verticalSpacing: 12) {
          ForEach(shelfModel.games) { game in
            let plat_id = PlatformLookup.getPlaformName(platformID: Int(game.platform_id!)!)
            if(plat_id == self.platformFilterID || self.platformFilterID == "All") {
              if game.title!.contains(searchText) || searchText.isEmpty {
                NavigationLink(destination: GameSheetView(game: game)) {
                  CardView(imageName: game.cover_art).hoverEffect(.lift)
                    .onAppear { loadingNewGame = false }
                    .contextMenu {
                      GameContextView(game: game)
                    }
                }
              }
              
            }
          }
        }.masonryPlacementMode(.order)
      }.searchable(text: $searchText)
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
