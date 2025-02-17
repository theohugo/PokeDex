import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case alphabetical = "Alphabétique"
    case stat = "Force"
    var id: String { self.rawValue }
}

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @ObservedObject private var favoriteManager = FavoriteManager.shared
    @State private var selectedPokemon: Pokemon? // Pokémon sélectionné pour la Sheet
    @State private var searchText: String = ""
    @State private var selectedType: String = "All"
    @State private var sortOption: SortOption = .alphabetical
    @State private var showFavoritesOnly: Bool = false // Nouveau filtre pour afficher uniquement les favoris

    // Computed property pour filtrer et trier la liste
    var filteredPokemons: [Pokemon] {
        var filtered = viewModel.pokemons

        // **Filtrage par nom**
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }

        // **Filtrage par type**
        if selectedType != "All" {
            filtered = filtered.filter { pokemon in
                pokemon.types.contains { $0.type.name.lowercased() == selectedType.lowercased() }
            }
        }

        // **Filtrage favoris**
        if showFavoritesOnly {
            filtered = filtered.filter { favoriteManager.isFavorite(id: $0.id) }
        }

        // **Tri**
        switch sortOption {
        case .alphabetical:
            filtered.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .stat:
            filtered.sort {
                let stat0 = $0.stats.first?.baseStat ?? 0
                let stat1 = $1.stats.first?.baseStat ?? 0
                return stat0 > stat1
            }
        }

        return filtered
    }

    // Liste des types disponibles (calculée dynamiquement)
    var availableTypes: [String] {
        let types = viewModel.pokemons.flatMap { $0.types.map { $0.type.name.capitalized } }
        let uniqueTypes = Array(Set(types))
        return ["All"] + uniqueTypes.sorted()
    }

    var body: some View {
        NavigationStack {
            List(filteredPokemons) { pokemon in
                Button(action: { selectedPokemon = pokemon }) {
                    HStack {
                        AsyncImage(url: URL(string: pokemon.imageURL)) { image in
                            image.resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }

                        Text(pokemon.name.capitalized)
                            .font(.headline)

                        Spacer()
                        
                        // **Ajout d'une étoile si le Pokémon est en favori**
                        if favoriteManager.isFavorite(id: pokemon.id) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Rechercher un Pokémon")
            .navigationTitle("Pokédex")
            .toolbar {
                // **Filtre par type**
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(availableTypes, id: \.self) { type in
                            Button(type) { selectedType = type }
                        }
                    } label: {
                        Label("Type: \(selectedType)", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
                // **Filtre favoris**
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFavoritesOnly.toggle()
                    }) {
                        Label("Favoris", systemImage: showFavoritesOnly ? "star.fill" : "star")
                            .foregroundColor(showFavoritesOnly ? .yellow : .primary)
                    }
                }
                // **Tri**
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases) { option in
                            Button(option.rawValue) { sortOption = option }
                        }
                    } label: {
                        Label("Trier", systemImage: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .sheet(item: $selectedPokemon) { pokemon in
                PokemonDetailView(pokemon: pokemon)
            }
            .task { viewModel.fetchPokemons() }
        }
    }
}

#Preview {
    ContentView()
}
