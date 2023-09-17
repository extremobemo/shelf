//
//  DrawerView.swift
//  shelf-proj
//
//  Created by Benjamin Morris on 9/16/23.
//

import Foundation
import SwiftUI
struct DrawerView: View {

  @ObservedObject private var shelfModel: ShelfModel

  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
    //self.columns = shelfModel.getColumns(count: 5)
  }

    var body: some View {
      NavigationView {
          List {
            Label("All", systemImage: "book")//.hoverEffect()
            Label("Sega Dreamcast", systemImage: "square")//.hoverEffect()
            Label("Nintendo 3DS", systemImage: "square")//.hoverEffect()
            Label("Metal Gear Solid", systemImage: "square")//.hoverEffect()
          }
          .navigationTitle("Shelf")
        CatalogueView(shelfModel: shelfModel).animation(.easeInOut(duration: 1.0), value: true)
      }
    }
}

