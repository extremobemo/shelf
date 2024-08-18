//
//  CustomShelfListRow.swift
//  shelf
//
//  Created by Bemo on 2/23/24.
//

import Foundation
import SwiftUI

struct CustomShelfListRow: View {
  
  let count: Int
  let shelf: Shelf
  
  var body: some View {
    
    HStack {
      Text(shelf.name!).contextMenu {
        Button(action: {
          CoreDataManager.shared.persistentStoreContainer.viewContext.delete(shelf.customShelf!)
          try? CoreDataManager.shared.persistentStoreContainer.viewContext.save()
          CoreDataManager.shared.persistentStoreContainer.viewContext.refreshAllObjects()
        }) { Text("Delete") }
        
        Button(action: {
            // Rename custom shelf
        }) { Text("Rename") }
      }
      
      Spacer()
      
      Capsule()
        .fill(Color(UIColor.systemGray5))
        .overlay(
          Text(String(shelf.customShelf?.game_ids?.count ?? 0))
            .font(.system(size: 12, weight: .medium))
        )
        .frame(width: 36, height: 24, alignment: .center)
      Image(systemName: "chevron.right")
      
    }
  }
}
