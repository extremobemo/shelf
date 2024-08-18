//
//  Carousel.swift
//  shelf
//
//  Created by Bemo on 3/3/24.
//

import Foundation


import SwiftUI

struct CarouselView: View {
  
  @State private var currentIndex = 0
  
  let images: [Data]
  let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
  private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
  
  var body: some View {
    GeometryReader { geo in
      VStack {
        TabView(selection: $currentIndex) {
          ForEach(0..<images.count, id: \.self) { index in
            ZStack(alignment: .topLeading) {
              AspectRatioImageView(uiImage: UIImage(data: images[index])!)
                .tag(index)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .shadow(radius: 20)
          }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        
      }.frame(maxWidth: geo.size.width, maxHeight: getCarouselHeight())
        .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
      
        .onReceive(timer) { _ in
          withAnimation(.default) {
            currentIndex = (currentIndex + 1) % images.count
          }
        }
    }
  }
  
  private func getCarouselHeight() -> CGFloat {
    if idiom == .pad {
      return 550
    } else {
      return 300
    }
  }
}
