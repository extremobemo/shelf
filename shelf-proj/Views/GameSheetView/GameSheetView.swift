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
      
      //replace with game.cover_art if you want
      
      //fix this so that another object creates the list of views based off game data.
      PageViewController(pages: [Image(uiImage: UIImage(data: game.cover_art!)!)
        .resizable()
        .aspectRatio(contentMode: .fit),
        Image(uiImage: UIImage(data: game.back_cover_art!)!)
         .resizable()
         .aspectRatio(contentMode: .fit),
        Image(uiImage: UIImage(data: game.screenshots![0])!)
        .resizable()
        .aspectRatio(contentMode: .fit),
       Image(uiImage: UIImage(data: game.screenshots![1])!)
         .resizable()
         .aspectRatio(contentMode: .fit),
       Image(uiImage: UIImage(data: game.screenshots![2])!)
         .resizable()
         .aspectRatio(contentMode: .fit),
       Image(uiImage: UIImage(data: game.screenshots![3])!)
         .resizable()
         .aspectRatio(contentMode: .fit),
       Image(uiImage: UIImage(data: game.screenshots![4])!)
         .resizable()
         .aspectRatio(contentMode: .fit)])

      //Image(uiImage: UIImage(data: game.screenshots![1])!).resizable()
       //     .aspectRatio(contentMode: .fit).frame(maxWidth: 600)
        Button("Press to dismiss") {
            dismiss()
        }.frame(height: 60)
        .font(.title)
        .padding()
      Text(game.title!)
      Text(game.desc!)
    }
}
