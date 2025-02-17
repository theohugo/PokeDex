import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case alphabetical = "Alphabétique"
    case stat = "Force"
    var id: String { self.rawValue }
}

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @ObservedObject private var favoriteManager = FavoriteManager.shared
    @State private var selectedPokemon: Pokemon?
    @State private var searchText: String = ""
    @State private var selectedType: String = "All"
    @State private var sortOption: SortOption = .alphabetical
    @State private var showFavoritesOnly: Bool = false
    @State private var showSettings: Bool = false  // **State for settings modal**
    
    // **Filter and sort Pokémon list**
    var filteredPokemons: [Pokemon] {
        var filtered = viewModel.pokemons
        
        // **Filter by name**
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // **Filter by type**
        if selectedType != "All" {
            filtered = filtered.filter { pokemon in
                pokemon.types.contains { $0.type.name.lowercased() == selectedType.lowercased() }
            }
        }
        
        // **Filter favorites**
        if showFavoritesOnly {
            filtered = filtered.filter { favoriteManager.isFavorite(id: $0.id) }
        }
        
        // **Sort**
        switch sortOption {
        case .alphabetical:
            filtered.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .stat:
            filtered.sort { pokemon1, pokemon2 in
                let averageStat1 = calculateAverageStat(for: pokemon1)
                let averageStat2 = calculateAverageStat(for: pokemon2)
                return averageStat1 > averageStat2
            }
        }
        
        return filtered
    }
    
    // **Available types for filtering**
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
                        // **Favorite star**
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
                // **Type filter button**
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(availableTypes, id: \.self) { type in
                            Button(type) { selectedType = type }
                        }
                    } label: {
                        Label("Type: \(selectedType)", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
                // **Favorites filter button**
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFavoritesOnly.toggle() }) {
                        Label("Favoris", systemImage: showFavoritesOnly ? "star.fill" : "star")
                            .foregroundColor(showFavoritesOnly ? .yellow : .primary)
                    }
                }
                // **Sort menu**
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases) { option in
                            Button(option.rawValue) { sortOption = option }
                        }
                    } label: {
                        Label("Trier", systemImage: "arrow.up.arrow.down.circle")
                    }
                }
                // **Settings button**
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(item: $selectedPokemon) { pokemon in
                PokemonDetailView(pokemon: pokemon)
            }
            // **Settings modal sheet with loading animation**
            .sheet(isPresented: $showSettings) {
                SettingsView(isLoading: $viewModel.isLoading) { newLimit in
                    viewModel.refreshPokemons(limit: newLimit)
                }
            }
            .task { viewModel.fetchPokemons() }
        }
    }
    
    /// **Calculate average stat for a Pokémon**
    private func calculateAverageStat(for pokemon: Pokemon) -> Double {
        guard !pokemon.stats.isEmpty else { return 0 }
        let totalStats = pokemon.stats.reduce(0) { $0 + Double($1.baseStat) }
        return totalStats / Double(pokemon.stats.count)
    }
}

#Preview {
    ContentView()
}
