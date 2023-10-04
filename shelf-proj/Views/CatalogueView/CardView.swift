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
    var body: some View {
        
    VStack {
        Image(uiImage: UIImage(data: imageName!)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    .cornerRadius(10)
    .overlay( RoundedRectangle(cornerRadius: 10)
        .stroke(Color(.sRGB,
                      red: 150/255,
                      green: 150/255,
                      blue: 150/255,
                      opacity: 0.3), lineWidth: 1))
    .padding([.horizontal])
    }
}
