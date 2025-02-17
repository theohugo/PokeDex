import Foundation

// MARK: - Service de récupération des Pokémon
class PokemonService {
    static let shared = PokemonService()
    private let baseURL = "https://pokeapi.co/api/v2/pokemon"

    func fetchPokemonList(limit: Int = 151) async throws -> [Pokemon] {
        let url = URL(string: "\(baseURL)?limit=\(limit)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decodedResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
        
        var pokemonList: [Pokemon] = []
        
        for result in decodedResponse.results {
            if let pokemon = try? await fetchPokemonDetail(url: result.url) {
                pokemonList.append(pokemon)
            }
        }
        
        return pokemonList
    }
    
    private func fetchPokemonDetail(url: String) async throws -> Pokemon {
        let url = URL(string: url)!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Pokemon.self, from: data)
    }
}

// MARK: - Struct pour la réponse JSON de la liste
struct PokemonListResponse: Codable {
    let results: [PokemonResult]
}

struct PokemonResult: Codable {
    let name: String
    let url: String
}
