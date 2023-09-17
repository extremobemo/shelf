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

  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
  }

    var body: some View {
      NavigationView {
          List {
            NavigationLink("All", destination: CatalogueView(shelfModel: shelfModel)).hoverEffect()
            Label("All", systemImage: "book").hoverEffect()
            Label("Sega Dreamcast", systemImage: "square").hoverEffect()
            Label("Nintendo 3DS", systemImage: "square").hoverEffect()
            Label("Metal Gear Solid", systemImage: "square").hoverEffect()
          }
          .navigationTitle("Shelf")
        CatalogueView(shelfModel: shelfModel).animation(.easeInOut(duration: 1.0), value: true)
      }
    }
}

