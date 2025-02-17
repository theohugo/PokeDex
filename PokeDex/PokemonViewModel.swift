import SwiftUI

// MARK: - ViewModel pour gérer la liste des Pokémon
class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading = false

    func fetchPokemons() {
        isLoading = true
        Task {
            do {
                let fetchedPokemons = try await PokemonService.shared.fetchPokemonList()
                DispatchQueue.main.async {
                    self.pokemons = fetchedPokemons
                    self.isLoading = false
                }
            } catch {
                print("Erreur lors du chargement des Pokémon : \(error)")
                isLoading = false
            }
        }
    }
}
