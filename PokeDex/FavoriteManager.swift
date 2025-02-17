import CoreData
import SwiftUI

class FavoriteManager: ObservableObject {
    static let shared = FavoriteManager()
    let context = CoreDataManager.shared.container.viewContext

    @Published var favorites: [Pokemon] = []

    init() {
        loadFavorites()
    }

    func addFavorite(pokemon: Pokemon) {
        let favorite = FavoritePokemonEntity(context: context)
        favorite.id = Int64(pokemon.id)
        favorite.name = pokemon.name
        favorite.imageURL = pokemon.imageURL

        save()
        loadFavorites() // Recharge la liste après ajout
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
            loadFavorites() // Recharge la liste après suppression
        } catch {
            print("❌ Erreur lors de la suppression : \(error)")
        }
    }

    func isFavorite(id: Int) -> Bool {
        return favorites.contains { $0.id == id }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            print("❌ Erreur lors de la sauvegarde : \(error)")
        }
    }

    func loadFavorites() {
        let request: NSFetchRequest<FavoritePokemonEntity> = FavoritePokemonEntity.fetchRequest()
        do {
            let cachedFavorites = try context.fetch(request)
            self.favorites = cachedFavorites.map { entity in
                Pokemon(
                    id: Int(entity.id),
                    name: entity.name ?? "",
                    sprites: Sprites(frontDefault: entity.imageURL ?? ""),
                    types: [],
                    stats: []
                )
            }
        } catch {
            print("❌ Erreur lors du chargement des favoris : \(error)")
        }
    }
}
