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
  
    @ObservedObject private var shelfModel: ShelfModel
    
    @FetchRequest(
            sortDescriptors: [],
            animation: .default)
  
  
    private var games: FetchedResults<Game>

    
    
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
    @State var showingScanner = false
    @State private var popoverPhoto: String = ""
    @State private var game: String?
    @State private var platform_name: String?
    @State private var newGame = false
   
    @State private var gameID: String?
    //var games = [Game]()
    
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
                    // TODO: Create function to add new card to home screen with game info
                }.padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
               
                ScrollView() {
                    HStack(alignment: .top, spacing: -15) {
                        ForEach( 0 ..< 5, id: \.self) { spandex in
                            LazyVStack(spacing: 15) {
//                                //ForEach( 0 ..< 10) {_ in
                                ForEach(shelfModel.columns[spandex].indices, id: \.self) { index in
                                    let photoIndex = index

                                       CardView(imageName: shelfModel.columns[spandex][index].cover_art).onTapGesture {
                                            showingPopover = true
                                            popoverPhoto = images[photoIndex]
                                      }.id(UUID())
                                  }
                             }
                        }
                    }
                }
            }.gesture(pinch).sheet(isPresented: $showingPopover) { // TODO: Scroll view interfering with zoom gesture....
                GameSheetView(image: popoverPhoto, gameName: game!)
            }.sheet(isPresented: $newGame) {
                let test = game!.replacingOccurrences(of: "-", with: " ", options: NSString.CompareOptions.literal, range: nil).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "FAIL"
                let base_url = URL(string: "https://www.mobygames.com/search/?q=" + test)
                WebView(url: base_url!, shelfModel: shelfModel, platform_name: $platform_name ,gameID: $gameID)
                //newGame = false
            }
            .onChange(of: gameID) { _ in
              //shelfModel.getColumns(count: 5)
              newGame = false
            }
        }
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
                    
                    let test = navigationAction.request.url?.absoluteString.split(separator: "/").map { String($0) }
                    self.parent.gameID = test![3]
                                    let id = PlatformLookup.getPlatformID(platform: parent.platform_name!)

                    //print(test![3])
                  DispatchQueue.main.async {
                    self.parent.shelfModel.addGame(game: test![3], platform: id!) { done in
                    }
                    }
                }
                decisionHandler(.allow)
            }
            
        }

}


