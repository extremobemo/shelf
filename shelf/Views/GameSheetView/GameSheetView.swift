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
  }
}

struct GameSheetView: View {
  @Environment(\.dismiss) var dismiss
  var game: Game
  var body: some View {
    
    ScrollView(content: {
      
      VStack(alignment: .leading) {
        HStack {
          Spacer()
          
          
          if let screenshots = game.screenshots {
            let screenshotViews: [AspectRatioImageView] = screenshots.compactMap { screenshotData in
              let imageData = screenshotData
              let uiImage = UIImage(data: imageData)
              return AspectRatioImageView(uiImage: uiImage!)
            }
            let cover = AspectRatioImageView(uiImage: UIImage(data: game.cover_art!)!)
            let pageViewController = PageViewController(pages: [cover] + screenshotViews)
            pageViewController.frame(height: 550) // 250 for iphones, 550 for ipad
          }
          Spacer()
        }
        
        Spacer()
        Text("Genre").font(.title).fontWeight(.bold).foregroundStyle(.white)
        Spacer()
        HStack {
          Text("Genre")
          Spacer()
          Text(game.base_genre ?? "Not available")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        Divider()
        HStack {
          Text("Perspective")
          Spacer()
          Text(game.perspective ?? "Not available")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        Divider()
        
        HStack(alignment: .top) {
          Text("Gameplay")
          Spacer()
          Text(game.gameplayElems ?? "Not available").frame(maxWidth: 350, maxHeight: 48) //150 iphone, 350 ipad
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        Spacer()
        Text("Description").font(.title).fontWeight(.bold).foregroundStyle(.white)
        HTMLFormattedText(game.desc!).frame(height: 400).clipShape(.rect(cornerRadius: 4.0), style: .init())
      }
      .padding(EdgeInsets(top: 8.0, leading: 16.0, bottom: 0, trailing: 16.0))
      .font(.subheadline)
      .foregroundStyle(.secondary)
    }).navigationTitle(game.title!)
    
  }
}

struct HTMLFormattedText: UIViewRepresentable {
  
  let text: String
  private  let textView = UITextView()
  
  init(_ content: String) {
    self.text = content
  }
  
  func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
    textView.dataDetectorTypes = .link
    textView.isEditable = false
    textView.isUserInteractionEnabled = true
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.isScrollEnabled = false
    textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    textView.backgroundColor = .systemGray5
    return textView
  }
  
  func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
    DispatchQueue.main.async {
      if let attributeText = self.converHTML(text: text) {
        textView.attributedText = attributeText
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = UIColor.label
      } else {
        textView.text = ""
      }
      
    }
  }
  
  private func converHTML(text: String) -> NSAttributedString?{
    guard let data = text.data(using: .utf8) else {
      return nil
    }
    
    if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
      return attributedString
    } else{
      return nil
    }
  }
}
