import CoreData
import SwiftUI

class FavoriteManager {
    static let shared = FavoriteManager()
    let context = CoreDataManager.shared.container.viewContext

    func addFavorite(pokemon: Pokemon) {
        let favorite = FavoritePokemonEntity(context: context)
        favorite.id = Int64(pokemon.id)
        favorite.name = pokemon.name
        favorite.imageURL = pokemon.imageURL
        save()
    }

    func removeFavorite(id: Int) {
        let request: NSFetchRequest<FavoritePokemonEntity> = FavoritePokemonEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            save()
        } catch {
            print("Erreur lors de la suppression : \(error)")
        }
    }

    func isFavorite(id: Int) -> Bool {
        let request: NSFetchRequest<FavoritePokemonEntity> = FavoritePokemonEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)

        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            print("Erreur lors de la sauvegarde des favoris : \(error)")
        }
    }
}
