import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @ObservedObject var favoriteManager = FavoriteManager.shared
    @State private var showCombatMode: Bool = false
    
    // States for sprite animation
    @State private var spriteScale: CGFloat = 0.3
    @State private var spriteOpacity: Double = 0.0
    @State private var spriteRotation: Double = -10 // Oscillation effect
    
    // States for pokéball opening animation
    @State private var showOpeningOverlay: Bool = true
    @State private var circleScale: CGFloat = 0.1

    var body: some View {
        VStack {
            // **Sprite with delayed animation**
            AsyncImage(url: URL(string: pokemon.imageURL)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(radius: 10)
                    .scaleEffect(spriteScale)
                    .opacity(spriteOpacity)
                    .rotationEffect(.degrees(spriteRotation))
                    .onAppear {
                        // Delay sprite animation to let pokéball animation finish
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeOut(duration: 0.6)) {
                                spriteOpacity = 1.0
                            }
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.2)) {
                                spriteScale = 1.0
                                spriteRotation = 0
                            }
                        }
                    }
            } placeholder: {
                ProgressView()
            }
            
            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // **Display types**
            HStack {
                ForEach(pokemon.types, id: \.type.name) { type in
                    Text(type.type.name.capitalized)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            
            // **Display stats**
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
                            .animation(.easeInOut(duration: 0.5), value: stat.baseStat)
                    }
                }
            }
            .padding()
            
            // **Favorite button**
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
            
            // **Combat button**
            Button(action: {
                showCombatMode = true
            }) {
                Text("Combattre")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.vertical)
            .sheet(isPresented: $showCombatMode) {
                CombatView(playerPokemon: pokemon)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Détails de \(pokemon.name.capitalized)")
        // Overlay for pokéball opening animation
        .overlay(
            Group {
                if showOpeningOverlay {
                    GeometryReader { geometry in
                        ZStack {
                            VStack(spacing: 0) {
                                // Top half in red
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(height: geometry.size.height / 2)
                                // Bottom half in white
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: geometry.size.height / 2)
                            }
                            // Black circle in the center (pokéball shutter)
                            Circle()
                                .fill(Color.black)
                                .frame(width: 50, height: 50)
                                .scaleEffect(circleScale)
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                }
            }
        )
        .onAppear {
            // Pokéball opening animation:
            // The black circle expands to reveal the view underneath, then the overlay disappears.
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                circleScale = 5.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(Animation.easeInOut(duration: 0.3)) {
                    showOpeningOverlay = false
                }
            }
        }
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
