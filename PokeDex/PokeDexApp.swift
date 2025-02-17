//
//  PokeDexApp.swift
//  PokeDex
//
//  Created by Hugo RAGUIN on 2/17/25.
//

import SwiftUI

@main
struct PokeDexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
