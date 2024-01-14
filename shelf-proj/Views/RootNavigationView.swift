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

  @State var selection: String? = "All"

  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
    self.platforms = shelfModel.getAllPlatforms()
  }

  var body: some View {
      NavigationSplitView {
        ZStack {
          List(selection: $selection)
           {
            //NavigationLink("All", destination: CatalogueView(shelfModel: shelfModel, platform_id: nil)).hoverEffect()
             ForEach(["All"] + self.platforms, id: \.self) { (plat: String) in

               if plat == "All" {
                 NavigationLink("All", destination: CatalogueView(shelfModel: shelfModel, platform_id: nil)).hoverEffect()
               } else {

                 NavigationLink(plat,
                                destination: CatalogueView(shelfModel: shelfModel, platform_id: plat), tag: plat, selection: $selection).hoverEffect()
               }

            }
          }
        }
          .navigationTitle("Shelf")

          //CatalogueView(shelfModel: shelfModel, platform_id: nil).animation(.easeInOut(duration: 1.0), value: true)
      }

  detail: {
    CatalogueView(shelfModel: shelfModel, platform_id: nil).animation(.easeInOut(duration: 1.0), value: true)
  }
      .onAppear {
          // Set the initial value for selection to the identifier of "All"
          self.selection = "All"
      }
  }
}

