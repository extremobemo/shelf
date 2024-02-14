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
  @State var showingSection1 = true
  @State var showingSection2 = true
  
  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
    self.platforms = shelfModel.getAllPlatforms()
    self.gamecount = String(shelfModel.games.count)
  }
    
  var body: some View {
    NavigationSplitView() {
      
      List(selection: $selection) {
        Section(
          header: SectionHeader(
            title: "Catalogue",
            isOn: $showingSection1,
            onLabel: "Hide",
            offLabel: "Show"
          )
        ){
          if showingSection1 {
            ForEach([0] + platforms, id: \.self) { plat in
              HStack {
                Text(PlatformLookup.getPlaformName(platformID: plat) ?? "FAIL")
                Spacer()
                Capsule()
                  .fill(Color(UIColor.systemGray5))
                  .overlay(
                    Text(String(self.shelfModel.getGameCountForPlatform(platform: plat)))
                      .font(.system(size: 12, weight: .medium))
                  )
                  .frame(width: 36, height: 24, alignment: .center)
                Image(systemName: "chevron.right")
              }
            }
          }
        }
        
        Section(
          header: SectionHeader(
            title: "Custom Shelves",
            isOn: $showingSection2,
            onLabel: "Hide",
            offLabel: "Show"
          )
        ){
          if showingSection2 {
            Text("Beaten")
            Text("Backlog")
          }
        }
        // Text(plat)
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
      }.listStyle(SidebarListStyle())
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

