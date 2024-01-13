//
//  CatalogueView.swift
//  shelf-proj
//
//  Created by Benjamin Morris on 9/16/23.
//

import Foundation
import SwiftUI
import VisionKit
import AVKit
import WebKit
import CloudKit
import SwiftUIMasonry

struct CatalogueView: View {
  @Environment(\.managedObjectContext) private var viewContext
    
  @ObservedObject private var shelfModel: ShelfModel
    @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Game.title, ascending: true)],
    animation: .default)
    private var games: FetchedResults<Game>
  @State private var searchText = ""
    private var platform_id: String?
  private var console_id: String?

  private var mga = MobyGamesApi()
  let container = CKContainer(identifier: "iCloud.icloud.extremobemo.shelf-proj")


  init(shelfModel: ShelfModel, platform_id: String?) {
    self.shelfModel = shelfModel
    self.platform_id = platform_id
    //shelfModel.getColumns(count: numOfColumns, platform_id: platform_id)
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
  let plu = PlatformLookup()
  var body: some View {
    ScrollView(.vertical) {
      Masonry(.vertical, lines: 5, horizontalSpacing: 8, verticalSpacing: 8) {
        ForEach(self.games) { game in
            let plat_id = PlatformLookup.getPlaformName(platformID: Int(game.platform_id!)!)
            if(plat_id == self.platform_id || self.platform_id == nil) {
              if game.title!.contains(searchText) || searchText.isEmpty {
                CardView(imageName: game.cover_art).hoverEffect(.lift)
                    .onTapGesture {
                        selectedGame = game
                    }
                  .onChange(of: selectedGame, initial: false) { _, test in showingPopover = true }
                  .contextMenu {
                    Button {
                      let ckm = CloudKitManager()
                      ckm.getGameRecord(game: game)

                    } label: {
                      Label("Delete Game", systemImage: "globe")
                    }
                  }
              }
            }
        }
      }
    }.padding(EdgeInsets(top: 0, leading: 16.0, bottom: 0, trailing: 16.0))
    .sheet(isPresented: $showingPopover) { // TODO: Scroll view interfering with zoom gesture....
      if let selectedGame = selectedGame {
        GameSheetView(game: selectedGame)
      }
    }
    .navigationTitle("Catalogue")

    .toolbar {
      ToolbarItem() {
        Button(action: {
#if os(iOS)
          AVCaptureDevice.requestAccess(for: .video) { response in
            if response {
              showingScanner = true
            } else {
              showingScanner = false
            }
          }
#endif
          showingScanner = true }) {
            Image(systemName: "plus")
          }.sheet(isPresented: $showingScanner) {
            DataScanner(shelfModel: shelfModel, game: $game, platform_name: $platform_name)
          }.onChange(of: game, initial: false) { _, test in newGame = true }
          .hoverEffect(.automatic)
      }

    }.searchable(text: $searchText)
    .sheet(isPresented: $newGame) {
      let test = game!.replacingOccurrences(of: "-", with: " ", options: NSString.CompareOptions.literal, range: nil).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "FAIL"
      let base_url = URL(string: "https://www.mobygames.com/search/?q=" + test.unescaped)
      WebView(url: base_url!, shelfModel: shelfModel, platform_name: $platform_name ,gameID: $gameID)
    }
    .onChange(of: gameID, initial: false) { _, test in
      newGame = false
    }
    //CatalogueView(shelfModel: shelfModel)
  }
}


struct WebView: UIViewRepresentable {
  // 1
  var url: URL

  @ObservedObject var shelfModel: ShelfModel
  @Binding var platform_name: String?
  @Binding var gameID: String?

  // 3
  func updateUIView(_ webView: WKWebView, context: Context) {

    let request = URLRequest(url: url)
    webView.load(request)
  }

  func makeCoordinator() -> WebViewCoordinator {
    WebViewCoordinator(self)
  }

  func makeUIView(context: Context) -> WKWebView {
    let wKWebView = WKWebView()
    wKWebView.navigationDelegate = context.coordinator
    return wKWebView
  }

  class WebViewCoordinator: NSObject, WKNavigationDelegate {
    var parent: WebView

    init(_ parent: WebView) {
      self.parent = parent
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      let urlToMatch = parent.url.absoluteString

      if let urlStr = navigationAction.request.url?.absoluteString, urlStr != urlToMatch {
        if let test = navigationAction.request.url?.absoluteString.split(separator: "/").map({ String($0) }), test.count > 3 {
          self.parent.gameID = test[3]
          if let id = PlatformLookup.getPlatformID(platform: parent.platform_name!) {
            Task {
              do {
                  await self.parent.shelfModel.addGame(game: test[3], platform: id, platformString: parent.platform_name!)
                await self.parent.shelfModel.getColumns(count: 5)
              }
            }
          }
        }
        
      }
      decisionHandler(.allow)

    }
  }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
