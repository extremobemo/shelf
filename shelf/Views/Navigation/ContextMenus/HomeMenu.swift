//
//  HomeMenu.swift
//  shelf
//
//  Created by Bemo on 2/23/24.
//

import Foundation

import SwiftUI

struct HomeMenu: View {
  
  @StateObject var shelfModel: ShelfModel

  @Binding var presentAlert: Bool
  @Binding var shelfName: String
  
  init(shelfModel: ShelfModel, presentAlert: Binding<Bool>, shelfName: Binding<String>) {
    self._presentAlert = presentAlert
    self._shelfName = shelfName
    _shelfModel = StateObject(wrappedValue: shelfModel)
  }
  
  var body: some View {
    Menu {
      Button(action: { presentAlert = true }) {
        HStack {
          Text("New Shelf")
          Image(systemName: "plus")
        }
      }
    } label: {
      Button(action: { presentAlert = true }) {
        Image(systemName: "list.dash")
      }
      .alert("Create new", isPresented: $presentAlert, actions: {
        TextField("Custom Name", text: $shelfName)
        Button("Cancel", action: { })
        Button("Create", action: {
          Task {
            await shelfModel.createNewShelf(shelfName: shelfName)
          }
        })
      })
    }
  }
}
