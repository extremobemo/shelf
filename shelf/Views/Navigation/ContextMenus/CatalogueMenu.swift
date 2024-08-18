//
//  CatalogueMenu.swift
//  shelf
//
//  Created by Bemo on 2/23/24.
//

import Foundation
import SwiftUI

struct CatalogueMenu: View {
  
  @ObservedObject var viewModel: CatalogueViewModel
  
  init(viewModel: CatalogueViewModel) {
      self.viewModel = viewModel
  }
  
  var body: some View {
    
    Menu {
      if !viewModel.selectMode {
        if viewModel.selection?.customShelf == nil {
          Menu("Add Game...") {
            Button(action: {
              viewModel.showingScanner = true
            }) {
              HStack {
                Text("Scan Game")
                Image(systemName: "barcode.viewfinder")
              }
            }
            Button(action: {
              viewModel.presentingMobySearch = true
            }) {
              HStack {
                Text("Search")
                Image(systemName: "magnifyingglass")
              }
            }
          }
        }
       
        Button(action: { viewModel.selectMode = true }) {
          HStack {
            Text("Select")
            Image(systemName: "checkmark.circle")
          }
        }
        Button(action: { viewModel.sortByYear = !viewModel.sortByYear }) {
          HStack {
            Text("Sort by Year")
            Image(systemName: "calendar.day.timeline.leading")
          }
        }
      } else {
        Button(role: .destructive) { viewModel.selectMode = false } label: {
          Text("Cancel")
        }
        
        Button(action: { viewModel.selectingDestination = true
        }) {
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
