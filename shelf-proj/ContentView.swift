//
//  ContentView.swift
//  shelf-proj
//
//  Created by Bemo on 9/1/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Game.entity(), sortDescriptors: [])
    private var items: FetchedResults<Game>
    
    
    @State private var numOfColumns: Int = 2
    @State private var can_zoom: Bool = true
    @State private var showingPopover = false
    @State private var popoverPhoto: String = ""

    
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
                  "Image 7"]

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
            VStack(alignment: .leading) {
                Text(verbatim: "Catalogue").padding(EdgeInsets(top: 20, leading: 36, bottom: 20, trailing: 0)).frame(alignment: .leading).font(.headline).scaleEffect(2.0).foregroundColor(.gray)
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
            }.gesture(pinch).sheet(isPresented: $showingPopover) {
                GameSheetView(image: popoverPhoto)
            }
        }
    }
}

