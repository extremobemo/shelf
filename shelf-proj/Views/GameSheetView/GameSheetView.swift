//
//  GameSheetView.swift
//  shelf-proj
//
//  Created by Bemo on 9/7/22.
//

import SwiftUI
import CoreData
import Foundation

struct AspectRatioImageView: View {
    let uiImage: UIImage
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(BlurView())
    }
}

struct GameSheetView: View {
    @Environment(\.dismiss) var dismiss
  var game: Game
    var body: some View {

        if let screenshots = game.screenshots {
            let screenshotViews: [AspectRatioImageView] = screenshots.compactMap { screenshotData in
                let imageData = screenshotData
                let uiImage = UIImage(data: imageData)
                return AspectRatioImageView(uiImage: uiImage!)
            }
            let cover = AspectRatioImageView(uiImage: UIImage(data: game.cover_art!)!)
            //        .resizable()
            //        .aspectRatio(contentMode: .fit),

            let pageViewController = PageViewController(pages: [cover] + screenshotViews)
            pageViewController.padding(EdgeInsets(top: 12, leading: 8, bottom: 0, trailing: 8))
        }
        
      ScrollView(content: {
            Text(game.title!).font(.largeTitle)
                .multilineTextAlignment(.center)
                .bold()
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
        
        
        VStack(alignment: .leading) {
            HStack {
                Text("Genre")
                Spacer()
                Text("Action")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            Divider()
            HStack {
                Text("Perspective")
                Spacer()
                Text("First-person")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            Divider()

            HStack {
                Text("Gameplay")
                Spacer()
                Text("Arcade, Music / rhythm, Puzzle elements, Shooter")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
                    }
                    .padding()
        .font(.subheadline)
        .foregroundStyle(.secondary)
      //fix this so that another object creates the list of views based off game data.
//        Image(uiImage: UIImage(data: game.cover_art!)!)
//        .resizable()
//        .aspectRatio(contentMode: .fit),
//        
//        Image(uiImage: UIImage(data: game.back_cover_art!)!)
//         .resizable()
//         .aspectRatio(contentMode: .fit)])
        
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

        //.font(.title)
        //.padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
        
            Text(game.desc!)
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
        })
        
    }
}
