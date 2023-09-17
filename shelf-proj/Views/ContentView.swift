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
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject private var shelfModel: ShelfModel
  
  @FetchRequest(
    sortDescriptors: [],
    animation: .default)
  
  private var games: FetchedResults<Game>
  private var mga = MobyGamesApi()
  
  init(shelfModel: ShelfModel) {
    self.shelfModel = shelfModel
    //self.columns = shelfModel.getColumns(count: 5)
  }
  
  // TODO: Spacing, styling, etc.
  // TODO: MacOS specific stuff for views...
  
  @State private var numOfColumns: Int = 5
  @State private var columns: [[Game]] = [[]]
  
  @State private var can_zoom: Bool = true
  @State private var showingPopover = false
  @State private var gametoshow: Game?
  @State var showingScanner = false
  @State private var popoverPhoto: String = ""
  @State private var game: String?
  @State private var platform_name: String?
  @State private var newGame = false
  @State private var selectedGame: Game? = nil
  @State private var gameID: String?
  
  var attributedString = AttributedString("Catalogue")
  let color = AttributeContainer.font(.boldSystemFont(ofSize: 48))
  
  var body: some View {
   // GeometryReader { geometry in
//      VStack() {
 //       HStack() {
//          Text(verbatim: "Catalogue").font(.largeTitle).scaleEffect(1.0).foregroundColor(.gray)
//          Spacer()
//          Button(action: {
//            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
//              if response {
//                showingScanner = true
//              } else {
//                showingScanner = false
//              }
//            }
//            showingScanner = true }) {
//              Image(systemName: "plus")
//            }.sheet(isPresented: $showingScanner) {
//              DataScanner(shelfModel: shelfModel, game: $game, platform_name: $platform_name)
//            }.onChange(of: game) { _ in newGame = true }
//        }.padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))

        DrawerView(shelfModel: shelfModel)
        //CatalogueView(shelfModel: shelfModel)
      }
    }
  //}

