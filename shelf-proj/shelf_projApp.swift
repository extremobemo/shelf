//
//  shelf_projApp.swift
//  shelf-proj
//
//  Created by Bemo on 9/1/22.
//

import SwiftUI

@main
struct shelf_projApp: App {
    let viewContext = CoreDataManager.shared.persistentStoreContainer.viewContext
    var body: some Scene {
        WindowGroup {
            ContentView(shelfModel: ShelfModel(context: viewContext))
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
