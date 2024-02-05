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
  private var platforms: [String]
  
  @State var showingScanner = false
  @State var selection: String? = "Catalogue"
  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
    self.platforms = shelfModel.getAllPlatforms()
  }
    
  var body: some View {
    NavigationSplitView() {
      List(["Catalogue"] + self.platforms, id: \.self, selection: $selection) { plat in
        Text(plat)
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
                  showingScanner: $showingScanner).navigationTitle(selection ?? "Catalogue").toolbar {
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

