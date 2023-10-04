//
//  GameSheetView.swift
//  shelf-proj
//
//  Created by Bemo on 9/7/22.
//

import SwiftUI
import CoreData
import Foundation


var desc = ""
struct GameSheetView: View {
    @Environment(\.dismiss) var dismiss
  var game: Game
    var body: some View {
        Text(game.title!).font(.largeTitle)
            .multilineTextAlignment(.center)
            .bold()
            .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
      
      //fix this so that another object creates the list of views based off game data.
      PageViewController(pages: [
        Image(uiImage: UIImage(data: game.cover_art!)!)
        .resizable()
        .aspectRatio(contentMode: .fit),
        
        Image(uiImage: UIImage(data: game.back_cover_art!)!)
         .resizable()
         .aspectRatio(contentMode: .fit)])
        
//        Image(uiImage: UIImage(data: game.screenshots![0])!)
//        .resizable()
//        .aspectRatio(contentMode: .fit),
//        
//       Image(uiImage: UIImage(data: game.screenshots![1])!)
//         .resizable()
//         .aspectRatio(contentMode: .fit),
//        
//       Image(uiImage: UIImage(data: game.screenshots![2])!)
//         .resizable()
//         .aspectRatio(contentMode: .fit),
//        
//       Image(uiImage: UIImage(data: game.screenshots![3])!)
//         .resizable()
//         .aspectRatio(contentMode: .fit),
//        
//       Image(uiImage: UIImage(data: game.screenshots![4])!)
//         .resizable()
//         .aspectRatio(contentMode: .fit)])

        .font(.title)
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
        ScrollView(content: {
            Text(game.desc!)
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
        })
        
    }
}
