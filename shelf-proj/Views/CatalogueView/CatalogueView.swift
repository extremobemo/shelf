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

struct CatalogueView: View {
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
    GeometryReader { geometry in
      ScrollView() {
        HStack(alignment: .top, spacing: -15) {
          ForEach( 0 ..< 5, id: \.self) { spandex in
            VStack(spacing: 15) {
              ForEach(shelfModel.columns[spandex], id: \.self) { (game: Game) in
                CardView(imageName: game.cover_art).hoverEffect(.lift).onTapGesture {
                  selectedGame = game
                  showingPopover = true
                }.sheet(isPresented: $showingPopover) { // TODO: Scroll view interfering with zoom gesture....
                  if let selectedGame = selectedGame {
                    GameSheetView(game: selectedGame)
                  }
                }
              }
            }
          }
        }
      }
    }.navigationTitle("Catalogue")
      .toolbar {
        ToolbarItem() {
          Button(action: {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
              if response {
                showingScanner = true
              } else {
                showingScanner = false
              }
            }
            showingScanner = true }) {
              Image(systemName: "plus")
            }.sheet(isPresented: $showingScanner) {
              DataScanner(shelfModel: shelfModel, game: $game, platform_name: $platform_name)
            }.onChange(of: game) { _ in newGame = true }
            .hoverEffect(.automatic)
        }

      }.sheet(isPresented: $newGame) {
        let test = game!.replacingOccurrences(of: "-", with: " ", options: NSString.CompareOptions.literal, range: nil).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "FAIL"
        let base_url = URL(string: "https://www.mobygames.com/search/?q=" + test.unescaped)
        WebView(url: base_url!, shelfModel: shelfModel, platform_name: $platform_name ,gameID: $gameID)
      }.onChange(of: gameID) { _ in
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
                await self.parent.shelfModel.addGame(game: test[3], platform: id)
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
