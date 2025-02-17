import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "PokedexModel") // Assure-toi que le nom correspond EXACTEMENT au fichier .xcdatamodeld
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Erreur lors du chargement du store : \(error)")
            }
        }
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Erreur lors de la sauvegarde : \(error)")
            }
        }
    }
}
