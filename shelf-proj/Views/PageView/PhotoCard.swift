//
//  PhotoCard.swift
//  shelf-proj
//
//  Created by Benjamin Morris on 9/15/23.
//

import Foundation
import SwiftUI

struct PhotoCard: View {
  var photo: UIImage
    var body: some View {
      Image(uiImage: photo).resizable()
            .aspectRatio(contentMode: .fit).frame(maxWidth: 600)
    }
}
