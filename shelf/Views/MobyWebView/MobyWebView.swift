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
  @Binding var platform_name: String?
  @Binding var isPresented: Bool
  @Binding var selectingPlatform: Bool
  @Binding var presentingMobySearch: Bool
  @Binding var searchedGame: String
  
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
          self.parent.loadingNewGame = true
          if (parent.platform_name != nil) {
            self.parent.isPresented = false
            if let id = PlatformLookup.getPlatformID(platform: parent.platform_name!) {
              Task {
                do {
                  await self.parent.shelfModel.addGame(game: test[3],
                                                       platform: id,
                                                       platformString: parent.platform_name!)
                }
              }
            }
          }
          else {
            if isValidMobyGamesURL(navigationAction.request.url?.absoluteString ?? "") {
              if let test = navigationAction.request.url?.absoluteString.split(separator: "/").map({ String($0) }), test.count > 3 {
                self.parent.presentingMobySearch = false
                self.parent.selectingPlatform = true
                self.parent.searchedGame = test[3]
              }
            } else {
              self.parent.isPresented = false
              // Probably should present some type of error to the user here.
            }
          }
        }
      }
      decisionHandler(.allow)
    }
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
