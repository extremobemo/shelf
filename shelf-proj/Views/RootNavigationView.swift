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
  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
    self.platforms = shelfModel.getAllPlatforms()
  }

    var body: some View {
      NavigationView {
          List {
              NavigationLink("All", destination: CatalogueView(shelfModel: shelfModel, platform_id: nil)).hoverEffect()
              ForEach(self.platforms, id: \.self) { (plat: String) in
                  NavigationLink(plat,
                                 destination: CatalogueView(shelfModel: shelfModel,
                                                            platform_id: nil)).hoverEffect()
              }
          }
          .navigationTitle("Shelf")
           CatalogueView(shelfModel: shelfModel, platform_id: nil).animation(.easeInOut(duration: 1.0), value: true)
      }
    }
}

