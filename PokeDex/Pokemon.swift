import SwiftUI

// MARK: - Modèle Pokémon
struct Pokemon: Identifiable, Codable {
    let id: Int
    let name: String
    let sprites: Sprites
    let types: [PokemonTypeWrapper]
    let stats: [StatWrapper]

    var imageURL: String {
        sprites.frontDefault
    }
}

// MARK: - Structs imbriquées pour l'API
struct Sprites: Codable {
    let frontDefault: String

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct PokemonTypeWrapper: Codable {
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
}

struct StatWrapper: Codable {
    let baseStat: Int
    let stat: Stat

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

struct Stat: Codable {
    let name: String
}
