import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case alphabetical = "Alphabétique"
    case stat = "Force"
    var id: String { self.rawValue }
}

struct ContentView: View {
    // **Dark/Light mode storage**
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    @StateObject private var viewModel = PokemonViewModel()
    @ObservedObject private var favoriteManager = FavoriteManager.shared
    @State private var selectedPokemon: Pokemon?
    @State private var searchText: String = ""
    @State private var selectedType: String = "All"
    @State private var sortOption: SortOption = .alphabetical
    @State private var showFavoritesOnly: Bool = false
    @State private var showSettings: Bool = false  // **Settings modal state**
    
    // **Computed filtered list with animated changes**
    var filteredPokemons: [Pokemon] {
        var filtered = viewModel.pokemons
        
        // **Filtre par nom**
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // **Filtre par type**
        if selectedType != "All" {
            filtered = filtered.filter { pokemon in
                pokemon.types.contains { $0.type.name.lowercased() == selectedType.lowercased() }
            }
        }
        
        // **Filtre favoris**
        if showFavoritesOnly {
            filtered = filtered.filter { favoriteManager.isFavorite(id: $0.id) }
        }
        
        // **Tri**
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
    
    // **Available types for filter menu**
    var availableTypes: [String] {
        let types = viewModel.pokemons.flatMap { $0.types.map { $0.type.name.capitalized } }
        let uniqueTypes = Array(Set(types))
        return ["All"] + uniqueTypes.sorted()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredPokemons) { pokemon in
                        Button {
                            // **Zoom effect on tap**
                            withAnimation {
                                selectedPokemon = pokemon
                            }
                        } label: {
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
                                
                                if favoriteManager.isFavorite(id: pokemon.id) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                        }
                        .buttonStyle(ZoomButtonStyle())
                        // **Animated transition for cards**
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
                // **Animation on filter/sort changes**
                .animation(.easeInOut, value: filteredPokemons)
            }
            .searchable(text: $searchText, prompt: "Rechercher un Pokémon")
            .navigationTitle("Pokédex")
            .toolbar {
                // **Menu for filtering by type**
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(availableTypes, id: \.self) { type in
                            Button(type) {
                                withAnimation { selectedType = type }
                            }
                        }
                    } label: {
                        Label("Type: \(selectedType)", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
                // **Dark/Light mode toggle**
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                    }
                }
                // **Favorites filter button**
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { showFavoritesOnly.toggle() }
                    } label: {
                        Label("Favoris", systemImage: showFavoritesOnly ? "star.fill" : "star")
                            .foregroundColor(showFavoritesOnly ? .yellow : .primary)
                    }
                }
                // **Sort menu**
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases) { option in
                            Button(option.rawValue) {
                                withAnimation { sortOption = option }
                            }
                        }
                    } label: {
                        Label("Trier", systemImage: "arrow.up.arrow.down.circle")
                    }
                }
                // **Settings button**
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            // **Sheet for Pokemon detail**
            .sheet(item: $selectedPokemon) { pokemon in
                PokemonDetailView(pokemon: pokemon)
            }
            // **Settings modal**
            .sheet(isPresented: $showSettings) {
                SettingsView(isLoading: $viewModel.isLoading) { newLimit in
                    viewModel.refreshPokemons(limit: newLimit)
                }
            }
            .task { viewModel.fetchPokemons() }
        }
        // **Apply dark/light mode**
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    /// **Calcule la moyenne des stats d'un Pokémon**
    private func calculateAverageStat(for pokemon: Pokemon) -> Double {
        guard !pokemon.stats.isEmpty else { return 0 }
        let totalStats = pokemon.stats.reduce(0) { $0 + Double($1.baseStat) }
        return totalStats / Double(pokemon.stats.count)
    }
}

struct ZoomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
