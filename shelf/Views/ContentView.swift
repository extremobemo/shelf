//
//  ContentView.swift
//  shelf-proj
//
//  Created by Bemo on 9/1/22.
//

import SwiftUI
import CoreData
import VisionKit
import AVKit

struct ContentView: View {

  @ObservedObject private var shelfModel: ShelfModel

  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
  }
  
  var body: some View {
    RootNavigationView(shelfModel: shelfModel)
  }
}

