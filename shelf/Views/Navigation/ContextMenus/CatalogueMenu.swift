//
//  CatalogueMenu.swift
//  shelf
//
//  Created by Bemo on 2/23/24.
//

import Foundation
import SwiftUI

struct CatalogueMenu: View {
  
  @Binding var selectMode: Bool
  @Binding var showingScanner: Bool
  @Binding var sortByYear: Bool
  @Binding var selectingDestination: Bool
  
  var body: some View {
    
    Menu {
      if !selectMode {
        Button(action: { showingScanner = true }) {
          HStack {
            Text("Scan Game")
            Image(systemName: "barcode.viewfinder")
          }
        }
        Button(action: { selectMode = true }) {
          HStack {
            Text("Select")
            Image(systemName: "checkmark.circle")
          }
        }
        Button(action: { sortByYear = !sortByYear }) {
          HStack {
            Text("Sort by Year")
            Image(systemName: "calendar.day.timeline.leading")
          }
        }
      } else {
        Button(role: .destructive) { selectMode = false } label: {
          Text("Cancel")
        }
        Button(action: { sortByYear = !sortByYear }) {
          HStack {
            Text("Sort by Year")
            Image(systemName: "calendar.day.timeline.leading")
          }
        }
        Button(action: { selectingDestination = true }) {
          HStack {
            Text("Add to...")
            Image(systemName: "plus")
          }
        }
      }
    } label: {
      Button(action: { }) {
        Image(systemName: "ellipsis.circle")
      }
    }
  }
}
