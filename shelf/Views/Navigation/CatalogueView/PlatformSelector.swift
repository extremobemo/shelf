//
//  ConsoleSelector.swift
//  shelf
//
//  Created by Bemo on 2/24/24.
//

import Foundation
import SwiftUI

struct PlatformSelector: View {
 
  @StateObject var shelfModel: ShelfModel
  @Binding var searchedGame: String
  @Binding var selectingPlatform: Bool
  
  @State private var searchText: String = ""


  init(shelfModel: ShelfModel, searchedGame: Binding<String>, selectingPlatform: Binding<Bool>) {
    
    self._searchedGame = searchedGame
    self._selectingPlatform = selectingPlatform
    
    _shelfModel = StateObject(wrappedValue: shelfModel)
  }
 
  var body: some View {
    NavigationView {
      VStack {
        List() {
          Section() {
            ForEach(shelfModel.getAllPlatforms(), id: \.self) { p in
              Button(action: {
                selectingPlatform = false
                Task {
                  do {
                    await shelfModel.addGame(game: searchedGame,
                                                         platform: p.platform_id ?? 0,
                                                         platformString: PlatformLookup.getPlaformName(platformID: p.platform_id ?? 0) ?? "This one shouldn't be here")
                  }
                }
              }) {
                HStack {
                  Text(String(PlatformLookup.getPlaformName(platformID: p.platform_id ?? 0) ?? "This one shouldn't be here"))
                  Spacer()
                  Image(systemName: "plus")
                }
              }
            }
          } header: {
            Text("My platforms")
          }
          
          Section() {
            let plats = PlatformLookup.getAllPlatformNames()
            let names = plats.map { $0.0 }
            let ids = plats.map { $0.1 }
            ForEach(names.indices) { index in
            
              Button(action: {
                selectingPlatform = false
                Task {
                  do {
                    await shelfModel.addGame(game: searchedGame,
                                                   platform: ids[index],
                                                   platformString: names[index])
                  }
                }
              }) {
                HStack {
                  Text(names[index])
                  Spacer()
                  Image(systemName: "plus")
                }
              }
            }
          } header: {
            Text("Other")
          }
        } .searchable(text: $searchText)
      }
     
      .navigationTitle("Select Platform...")
    }
  }
}
