//
//  MobyWebView.swift
//  shelf
//
//  Created by Bemo on 1/14/24.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
  
  var url: URL
  
  @Binding var loadingNewGame: Bool
  
  @ObservedObject var shelfModel: ShelfModel
  
  @ObservedObject var catalogueModel: CatalogueViewModel
  @ObservedObject var dataScannerModel: DataScannerViewModel
  
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
      
      guard let urlStr = navigationAction.request.url?.absoluteString, urlStr != urlToMatch else { decisionHandler(.allow); return }
      guard let gameName = navigationAction.request.url?.absoluteString.split(separator: "/").map({ String($0) })[3] else { decisionHandler(.allow); return }
      
      parent.loadingNewGame = true
      
      guard let platform = parent.dataScannerModel.scannedGamePlatform else {
        if parent.isValidMobyGamesURL(navigationAction.request.url?.absoluteString ?? "") {
          if let test = navigationAction.request.url?.absoluteString.split(separator: "/").map({ String($0) }), test.count > 3 {
            parent.catalogueModel.presentingMobySearch = false
            parent.catalogueModel.selectingPlatform = true
            parent.catalogueModel.searchedGame = test[3]
          }
        } else {
          parent.catalogueModel.presentingMobySearch = false
          // Probably should present some type of error to the user here.
        }
        decisionHandler(.allow)
        return
      }
      parent.catalogueModel.presentingMobySearch = false
      parent.dataScannerModel.scannedGamePlatform = nil
      if let id = PlatformLookup.getPlatformID(platform: platform) {
        Task {
          do {
            await parent.shelfModel.addGame(game: gameName, platform: id, platformString: platform)
          }
        }
      }
      decisionHandler(.allow)
    }
  }
  
  func isValidMobyGamesURL(_ urlString: String) -> Bool {
    // Regular expression pattern to match "https://www.mobygames.com/game/"
    let pattern = #"^https:\/\/www\.mobygames\.com\/game\/.*"#
    
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
      return false
    }
    
    return regex.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count)) != nil
  }
}
