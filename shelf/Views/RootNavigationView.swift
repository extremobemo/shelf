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
  
  @State var selection: String? = nil
  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
    self.platforms = shelfModel.getAllPlatforms()
  }
  
  var body: some View {
    NavigationSplitView {
      List(["All"] + self.platforms, id: \.self, selection: $selection) { plat in
        Text(plat)
      }.navigationTitle("Shelf")
    }
  detail: {
    if selection == "All" {
      CatalogueView(shelfModel: shelfModel, platformFilterID: nil).navigationTitle("Catalogue")
    } else {
      CatalogueView(shelfModel: shelfModel, platformFilterID: selection).navigationTitle(selection ?? "Catalogue")
    }
  }
    
  }
}

