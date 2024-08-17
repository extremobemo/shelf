//
//  ListRow.swift
//  shelf
//
//  Created by Bemo on 2/23/24.
//

import Foundation
import SwiftUI

struct ConsoleListRow: View {
    
  let platformID: Int?
  let count: Int
  
  var body: some View {
    
    HStack {
      Text(PlatformLookup.getPlaformName(platformID: platformID!) ?? "All")
      Spacer()
      Capsule()
        .fill(Color(UIColor.systemGray5))
        .overlay(Text(String(count)).font(.system(size: 12, weight: .medium)))
        .frame(width: 36, height: 24, alignment: .center)
      Image(systemName: "chevron.right")
    }
  }
}
