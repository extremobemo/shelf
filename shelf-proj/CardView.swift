//
//  CardView.swift
//  shelf-proj
//
//  Created by Bemo on 9/1/22.
//

import SwiftUI

struct CardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Game.entity(), sortDescriptors: [])
    private var items: FetchedResults<Game>
    
    let imageName: String
    var body: some View {
        
    VStack {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
        
        HStack {
            VStack(alignment: .leading) {
                Text(items[0].title ?? "Error!")
                    .font(.system(size: 12))
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                Text("Rockstar Games")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(items[0].system ?? "Error!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .layoutPriority(1)
            Spacer()
        }
        .padding()
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
