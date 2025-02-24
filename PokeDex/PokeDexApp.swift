import SwiftUI

@main
struct PokeDexApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.scheduleDailyReminder()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
