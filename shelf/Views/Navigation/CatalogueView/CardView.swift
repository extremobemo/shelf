//
//  CardView.swift
//  shelf-proj
//
//  Created by Bemo on 9/1/22.
//

import SwiftUI

struct CardView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  let imageName: Data?
  let gameTitle: String
  
  var body: some View {
    
    VStack {
      if let data = imageName {
        Image(uiImage: UIImage(data: data)!)
          .resizable()
          .aspectRatio(contentMode: .fit)
      } else {
        Spacer().frame(height: 40)
        Text(gameTitle)
          .frame(maxWidth: .infinity)
          .multilineTextAlignment(.center)
          .foregroundColor(.white)
        Spacer().frame(height: 40)
      }
    }
    .cornerRadius(4)
    .overlay( RoundedRectangle(cornerRadius: 4)
    .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 1))
  }
}
