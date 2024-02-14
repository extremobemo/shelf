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
  private var platforms: [Int]
  let gamecount: String
  
  @State var showingScanner = false
  @State var selection: Int? = 0
  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
    self.platforms = shelfModel.getAllPlatforms()
    self.gamecount = String(shelfModel.games.count)
  }
    
  var body: some View {
    NavigationSplitView() {
      List([0] + self.platforms, id: \.self, selection: $selection) { plat in
        HStack {
          Text(PlatformLookup.getPlaformName(platformID: plat) ?? "FAIL")
          Spacer()
          
          Capsule()
            .fill(Color(UIColor.darkGray))
                  .overlay(
                    Text(String(self.shelfModel.getGameCountForPlatform(platform: plat))).font(.system(size: 12,
                                                                                                       weight: .medium))
                  )
                  .frame(width: 36, height: 24, alignment: .center)
          
          Image(systemName: "chevron.right")
          
        }
      }.navigationTitle("Shelf").toolbar {
        ToolbarItem() {
          Menu {
            Button(action: {
              // Action for Menu Item 1
            }) {
              HStack {
                Text("New Shelf")
                Image(systemName: "plus")
              }
            }
          } label: {
            Button(action: { }) {
              Image(systemName: "list.dash")
            }
          }
        }
      }
      
      
      
    }
  detail: {
    CatalogueView(shelfModel: shelfModel,
                  platformFilterID: selection,
                  showingScanner: $showingScanner).navigationTitle(PlatformLookup.getPlaformName(platformID: selection ?? 0 ) ?? "FAIL").toolbar {
      ToolbarItem() {
        Menu {
          Button(action: {
            showingScanner = true
          }) {
            HStack {
              Text("Scan Game")
              Image(systemName: "barcode.viewfinder")
            }
          }
        } label: {
          Button(action: { }) {
            Image(systemName: "ellipsis.circle")
          }
        }
        .id(UUID())
      }
    }
  }
  }
  
}

