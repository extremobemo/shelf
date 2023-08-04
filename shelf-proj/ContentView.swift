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
import WebKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Game.entity(), sortDescriptors: [])
    private var items: FetchedResults<Game>
    
    // TODO: Spacing, styling, etc.
    // TODO: MacOS specific stuff for views...
    
    @State private var numOfColumns: Int = 5
    @State private var can_zoom: Bool = true
    @State private var showingPopover = false
    @State var showingScanner = false
    @State private var popoverPhoto: String = ""
    @State private var game: String?
    @State private var newGame = false
   
    
    var games = [Game]()
    
    var images = ["jgr",
                  "x",
                  "Image",
                  "Image 1",
                  "Image 2",
                  "Image 3",
                  "Image 4",
                  "Image 5",
                  "Image 6",
                  "Image 7"] // TODO: Drop this stuff, start storing game info in the CoreData Game

    var attributedString = AttributedString("Catalogue")
    let color = AttributeContainer.font(.boldSystemFont(ofSize: 48))
    
    var body: some View {
        let pinch = MagnificationGesture().onChanged{  delta in
            guard numOfColumns > 0 else {
                return
            }
            if delta >= 3 && can_zoom {
                numOfColumns -= 1
                can_zoom = false
            }
            if delta <= 0.5 && can_zoom {
                numOfColumns += 1
                can_zoom = false
            }
        }.onEnded{ _ in can_zoom = true }
        
        GeometryReader { geometry in
            VStack() {
                HStack() {
                    Text(verbatim: "Catalogue").font(.largeTitle).scaleEffect(1.0).foregroundColor(.gray)
                    Spacer()
                    Button(action: {
//                        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
//                               if response {
//                                  showingScanner = true
//                               } else {
//                                   showingScanner = false
//                               }
//                           }
                        showingScanner = true }) {
                        Image(systemName: "plus")
                    }.sheet(isPresented: $showingScanner) {
                        DataScanner(game: $game)
                    }.onChange(of: game) { _ in newGame = true } // TODO: Create function to add new card to home screen with game info
                }.padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
               
                ScrollView() {
                    HStack(alignment: .top, spacing: -15) {
                        ForEach( 0 ..< numOfColumns, id: \.self) { _ in
                            LazyVStack(spacing: 15) {
                                ForEach( 0 ..< 30) {_ in
                                    let photoIndex = Int.random(in: 0 ... 9)
                                    CardView(imageName: images[photoIndex]).onTapGesture {
                                        showingPopover = true
                                        popoverPhoto = images[photoIndex]
                                    }
                                }
                            }
                        }
                    }
                }
            }.gesture(pinch).sheet(isPresented: $showingPopover) { // TODO: Scroll view interfering with zoom gesture....
                GameSheetView(image: popoverPhoto, gameName: game ?? "FAIL")
            }.sheet(isPresented: $newGame) {
                let test = game!.replacingOccurrences(of: "-", with: " ", options: NSString.CompareOptions.literal, range: nil).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "FAIL"
                
                let base_url = URL(string: "https://www.mobygames.com/search/?q=" + test)
                
                
                WebView(url: base_url!)
                //newGame = false
            }
        }
    }
}






struct WebView: UIViewRepresentable {
    // 1
    var url: URL
    
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
                    print("NAV!")
                    print(navigationAction.request.url?.absoluteString)
                }
                decisionHandler(.allow)
            }
            
        }

}


