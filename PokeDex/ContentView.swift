import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var selectedPokemon: Pokemon? // Stocke le Pokémon sélectionné

    var body: some View {
        NavigationStack {
            List(viewModel.pokemons) { pokemon in
                Button(action: {
                    selectedPokemon = pokemon
                }) {
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
                    }
                }
            }
            .navigationTitle("Pokédex")
            .task {
                viewModel.fetchPokemons()
            }
            .sheet(item: $selectedPokemon) { pokemon in
                PokemonDetailView(pokemon: pokemon)
            }
        }
    }
}


#Preview {
    ContentView()
}
