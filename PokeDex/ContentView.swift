import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.pokemons) { pokemon in
                HStack {
                    AsyncImage(url: URL(string: pokemon.imageURL)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                    Text(pokemon.name.capitalized)
                        .font(.headline)
                }
            }
            .navigationTitle("Pokédex")
            .task {
                viewModel.fetchPokemons()
            }
        }
    }
}

#Preview {
    ContentView()
}
