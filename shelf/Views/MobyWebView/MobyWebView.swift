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
  var platform_name: String?
  @Binding var isPresented: Bool
  
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
        self.parent.loadingNewGame = true
        if let test = navigationAction.request.url?.absoluteString.split(separator: "/").map({ String($0) }), test.count > 3 {
          self.parent.isPresented = false
          if let id = PlatformLookup.getPlatformID(platform: parent.platform_name!) {
            Task {
              do {
                await self.parent.shelfModel.addGame(game: test[3],
                                                     platform: id,
                                                     platformString: parent.platform_name!)
                
                // await self.parent.shelfModel.getColumns(count: 5)
                
              }
            }
          }
        }
      }
      decisionHandler(.allow)
    }
  }
}