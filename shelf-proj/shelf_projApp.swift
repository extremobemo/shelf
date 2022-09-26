//
//  shelf_projApp.swift
//  shelf-proj
//
//  Created by Bemo on 9/1/22.
//

import SwiftUI

@main
struct shelf_projApp: App {
    let persistenceController = PersistenceController.preview

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
