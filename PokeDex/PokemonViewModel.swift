import SwiftUI
import CoreData

class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading = false

    func fetchPokemons() {
        isLoading = true

        // Chargement du cache CoreData
        let cachedPokemons = loadCachedPokemons()
        if !cachedPokemons.isEmpty {
            self.pokemons = cachedPokemons
            self.isLoading = false
            return
        }

        // Récupération via l'API
        Task {
            do {
                let fetchedPokemons = try await PokemonService.shared.fetchPokemonList()
                DispatchQueue.main.async {
                    self.pokemons = fetchedPokemons
                    self.savePokemonsToCache(pokemons: fetchedPokemons)
                    self.isLoading = false
                }
            } catch {
                print("Erreur lors du chargement des Pokémon : \(error)")
                isLoading = false
            }
        }
    }
    
    // Sauvegarde en cache avec CoreData
    private func savePokemonsToCache(pokemons: [Pokemon]) {
        let context = CoreDataManager.shared.container.viewContext

        for pokemon in pokemons {
            let entity = PokemonEntity(context: context)
            entity.id = Int64(pokemon.id)
            entity.name = pokemon.name
            entity.imageURL = pokemon.imageURL

            // Sauvegarde des statistiques
            for stat in pokemon.stats {
                let statEntity = PokemonStatEntity(context: context)
                statEntity.name = stat.stat.name
                statEntity.baseStat = Int64(stat.baseStat)
                statEntity.pokemon = entity
            }
        }

        CoreDataManager.shared.saveContext()
    }

    
    // Chargement du cache depuis CoreData
    private func loadCachedPokemons() -> [Pokemon] {
        let context = CoreDataManager.shared.container.viewContext
        let request: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()

        do {
            let cachedEntities = try context.fetch(request)
            return cachedEntities.map { entity in
                let stats = (entity.stats as? Set<PokemonStatEntity>)?.map { statEntity in
                    StatWrapper(baseStat: Int(statEntity.baseStat), stat: Stat(name: statEntity.name ?? ""))
                } ?? []

                return Pokemon(
                    id: Int(entity.id),
                    name: entity.name ?? "",
                    sprites: Sprites(frontDefault: entity.imageURL ?? ""),
                    types: [], // Si tu veux stocker les types, il faudra les ajouter aussi
                    stats: stats
                )
            }
        } catch {
            print("❌ Erreur lors du chargement du cache : \(error)")
            return []
        }
    }

}
