import SwiftUI
import CoreData

class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading = false
    
    func fetchPokemons() {
        isLoading = true
        
        // **Load CoreData cache**
        let cachedPokemons = loadCachedPokemons()
        if !cachedPokemons.isEmpty {
            self.pokemons = cachedPokemons
            isLoading = false
            return
        }
        
        // **Fetch via API**
        Task {
            do {
                let fetchedPokemons = try await PokemonService.shared.fetchPokemonList()
                DispatchQueue.main.async {
                    self.pokemons = fetchedPokemons
                    self.savePokemonsToCache(pokemons: fetchedPokemons)
                    self.isLoading = false
                }
            } catch {
                print("Error fetching Pokémon: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    // **Clear the CoreData cache**
    private func clearCache() {
        let context = CoreDataManager.shared.container.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = PokemonEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
    
    // **Force refresh without cache**
    func refreshPokemons(limit: Int) {
        isLoading = true
        clearCache() // **Clear previous cache**
        Task {
            do {
                let fetchedPokemons = try await PokemonService.shared.fetchPokemonList(limit: limit)
                DispatchQueue.main.async {
                    self.pokemons = fetchedPokemons
                    self.savePokemonsToCache(pokemons: fetchedPokemons)
                    self.isLoading = false
                }
            } catch {
                print("Error refreshing Pokémon: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    // **Save Pokémon to CoreData**
    private func savePokemonsToCache(pokemons: [Pokemon]) {
        let context = CoreDataManager.shared.container.viewContext
        
        for pokemon in pokemons {
            let entity = PokemonEntity(context: context)
            entity.id = Int64(pokemon.id)
            entity.name = pokemon.name
            entity.imageURL = pokemon.imageURL
            
            // **Save types**
            for type in pokemon.types {
                let typeEntity = PokemonTypeEntity(context: context)
                typeEntity.name = type.type.name
                typeEntity.pokemon = entity
            }
            
            // **Save stats**
            for stat in pokemon.stats {
                let statEntity = PokemonStatEntity(context: context)
                statEntity.name = stat.stat.name
                statEntity.baseStat = Int64(stat.baseStat)
                statEntity.pokemon = entity
            }
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    // **Load Pokémon from CoreData**
    private func loadCachedPokemons() -> [Pokemon] {
        let context = CoreDataManager.shared.container.viewContext
        let request: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        
        do {
            let cachedEntities = try context.fetch(request)
            return cachedEntities.map { entity in
                // **Retrieve types**
                let types = (entity.types as? Set<PokemonTypeEntity>)?.map { typeEntity in
                    PokemonTypeWrapper(type: PokemonType(name: typeEntity.name ?? "unknown"))
                } ?? []
                
                // **Retrieve stats**
                let stats = (entity.stats as? Set<PokemonStatEntity>)?.map { statEntity in
                    StatWrapper(baseStat: Int(statEntity.baseStat), stat: Stat(name: statEntity.name ?? ""))
                } ?? []
                
                return Pokemon(
                    id: Int(entity.id),
                    name: entity.name ?? "",
                    sprites: Sprites(frontDefault: entity.imageURL ?? ""),
                    types: types,
                    stats: stats
                )
            }
        } catch {
            print("Error loading cache: \(error)")
            return []
        }
    }
}
