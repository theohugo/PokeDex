import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @State private var isFavorite: Bool = false

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: pokemon.imageURL)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(radius: 10)
                    .transition(.scale) // Animation lors du chargement
            } placeholder: {
                ProgressView()
            }

            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)

            HStack {
                ForEach(pokemon.types, id: \.type.name) { type in
                    Text(type.type.name.capitalized)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
            }

            VStack(alignment: .leading) {
                Text("Statistiques")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                ForEach(pokemon.stats, id: \.stat.name) { stat in
                    HStack {
                        Text(stat.stat.name.capitalized)
                            .frame(width: 100, alignment: .leading)

                        ProgressView(value: Double(stat.baseStat), total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    }
                }
            }
            .padding()

            Button(action: {
                toggleFavorite()
            }) {
                Label(isFavorite ? "Retirer des Favoris" : "Ajouter aux Favoris", systemImage: isFavorite ? "star.fill" : "star")
                    .padding()
                    .background(isFavorite ? Color.yellow : Color.gray.opacity(0.3))
                    .cornerRadius(10)
            }
            .animation(.easeInOut, value: isFavorite)

            Spacer()
        }
        .padding()
        .navigationTitle("Détails de \(pokemon.name.capitalized)")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
            }
        }
    }

    private func toggleFavorite() {
        isFavorite.toggle()
        if isFavorite {
            FavoriteManager.shared.addFavorite(pokemon: pokemon)
        } else {
            FavoriteManager.shared.removeFavorite(id: pokemon.id)
        }
    }
}

#Preview {
    PokemonDetailView(pokemon: Pokemon(
        id: 1,
        name: "Bulbasaur",
        sprites: Sprites(frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"),
        types: [PokemonTypeWrapper(type: PokemonType(name: "grass"))],
        stats: [StatWrapper(baseStat: 45, stat: Stat(name: "hp"))]
    ))
}
