//
//  CardView.swift
//  shelf-proj
//
//  Created by Bemo on 9/1/22.
//

import SwiftUI

struct CardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    //@FetchRequest(entity: Game.entity(), sortDescriptors: [])
    //private var items: FetchedResults<Game>
    
    let imageName: Data?
    var body: some View {
        
    VStack {
        Image(uiImage: UIImage(data: imageName!)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
        
        HStack {
            VStack(alignment: .leading) {
                Text("Error!")
                    .font(.system(size: 12))
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                Text("Rockstar Games")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Error!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // TODO: Get this info from CoreData somehow
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
