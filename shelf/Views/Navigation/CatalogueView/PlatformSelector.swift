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
  
  @State var searchText: String = ""


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
            if searchText == "" {
              
              ForEach(shelfModel.getAllPlatforms(), id: \.self) { p in
                
                Button(action: {
                  selectingPlatform = false
                  Task {
                    do {
                      await shelfModel.addGame(game: searchedGame,
                                                           platform: p.platform_id ?? 0,
                                                           platformString: PlatformLookup.getPlaformName(platformID: p.platform_id ?? 0) ?? "error")
                    }
                  }
                }) {
                  HStack {
                    Text(String(PlatformLookup.getPlaformName(platformID: p.platform_id ?? 0) ?? "Any"))
                      .foregroundStyle(.white)
                  }
                }
              }
            } else {
              ForEach(shelfModel.getAllPlatforms().filter { p in
                print(searchText)
                return PlatformLookup.getPlaformName(platformID: p.platform_id ?? 0)?.contains(searchText) == true
              }, id: \.self) { p in
                
                Button(action: {
                  selectingPlatform = false
                  Task {
                    do {
                      await shelfModel.addGame(game: searchedGame,
                                                           platform: p.platform_id ?? 0,
                                                           platformString: PlatformLookup.getPlaformName(platformID: p.platform_id ?? 0) ?? "Any")
                    }
                  }
                }) {
                  HStack {
                    Text(String(PlatformLookup.getPlaformName(platformID: p.platform_id ?? 0) ?? "error"))
                      .foregroundStyle(.white)
                  }
                }
              }
            }

          } header: {
            Text("My platforms")
          }
          
          Section() {
            if searchText == "" {
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
                    Text(names[index]).foregroundStyle(.white)
                  }
                }
              }
            } else {
              let plats = PlatformLookup.getAllPlatformNames().filter { p in
                return p.0.contains(searchText)
              }
                            
              ForEach(plats, id: \.0) { plat in
              
                Button(action: {
                  selectingPlatform = false
                  Task {
                    do {
                      await shelfModel.addGame(game: searchedGame,
                                               platform: plat.1,
                                               platformString: plat.0)
                    }
                  }
                }) {
                  HStack {
                    // Text(plats[index].0)
                    Text(plat.0).foregroundStyle(.white)
                  }
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
