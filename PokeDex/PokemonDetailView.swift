import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @ObservedObject var favoriteManager = FavoriteManager.shared

    // États pour l'animation du sprite
    @State private var spriteScale: CGFloat = 0.3
    @State private var spriteOpacity: Double = 0.0
    @State private var spriteRotation: Double = -10 // Effet d'oscillation

    var body: some View {
        VStack {
            // Sprite avec animation améliorée (apparition + zoom + rotation)
            AsyncImage(url: URL(string: pokemon.imageURL)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(radius: 10)
                    .scaleEffect(spriteScale) // Effet de zoom progressif
                    .opacity(spriteOpacity) // Effet de fondu
                    .rotationEffect(.degrees(spriteRotation)) // Légère oscillation
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.6)) {
                            spriteOpacity = 1.0 // Apparition fluide
                        }
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.2)) {
                            spriteScale = 1.0 // Zoom progressif
                            spriteRotation = 0 // Rétablir la rotation
                        }
                    }
            } placeholder: {
                ProgressView()
            }

            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)

            // Affichage des types
            HStack {
                ForEach(pokemon.types, id: \.type.name) { type in
                    Text(type.type.name.capitalized)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
            }

            // Affichage des statistiques avec animation
            VStack(alignment: .leading) {
                Text("Statistiques")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                ForEach(pokemon.stats, id: \.stat.name) { stat in
                    HStack {
                        Text(stat.stat.name.capitalized)
                            .frame(width: 100, alignment: .leading)

                        ProgressView(value: Double(min(stat.baseStat, 100)), total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .animation(.easeInOut(duration: 0.5), value: stat.baseStat) // Animation fluide
                    }
                }
            }
            .padding()

            // Bouton Ajouter/Retirer des favoris
            Button(action: {
                toggleFavorite()
            }) {
                Label(favoriteManager.isFavorite(id: pokemon.id) ? "Retirer des Favoris" : "Ajouter aux Favoris",
                      systemImage: favoriteManager.isFavorite(id: pokemon.id) ? "star.fill" : "star")
                    .padding()
                    .background(favoriteManager.isFavorite(id: pokemon.id) ? Color.yellow : Color.gray.opacity(0.3))
                    .cornerRadius(10)
            }
            .animation(.easeInOut, value: favoriteManager.isFavorite(id: pokemon.id))

            Spacer()
        }
        .padding()
        .navigationTitle("Détails de \(pokemon.name.capitalized)")
    }

    private func toggleFavorite() {
        if favoriteManager.isFavorite(id: pokemon.id) {
            favoriteManager.removeFavorite(id: pokemon.id)
        } else {
            favoriteManager.addFavorite(pokemon: pokemon)
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
