import SwiftUI

struct GuessPokemonGameView: View {
    let pokemons: [Pokemon]
    @Environment(\.dismiss) var dismiss
    
    @State private var targetPokemon: Pokemon?
    @State private var options: [String] = []
    @State private var selectedOption: String? = nil
    @State private var isCorrect: Bool? = nil
    @State private var showResult: Bool = false
    @State private var score: Int = 0
    
    @State private var shadowScale: CGFloat = 1.0   // Animation de l'ombre
    @State private var spriteIdleOffset: CGFloat = 5  // Offset initial (pour animation haut/bas)
    
    // Nouveaux états pour animation de win et lose
    @State private var winScale: CGFloat = 1.0        // Pour l'animation de victoire (bounce)
    @State private var loseRotation: Double = 0.0     // Pour l'animation de défaite (shake)
    
    var body: some View {
        VStack(spacing: 20) {
            if let target = targetPokemon {
                ZStack {
                    // Ombre animée sous le Pokémon
                    Ellipse()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 150, height: 20)
                        .scaleEffect(shadowScale)
                        .offset(y: 110)
                    
                    // Le Pokémon avec animation idle, win/lose
                    AsyncImage(url: URL(string: target.imageURL)) { image in
                        Group {
                            if showResult {
                                image.resizable()
                            } else {
                                image.resizable().colorMultiply(.black)
                            }
                        }
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .offset(y: spriteIdleOffset)
                        // Animation de victoire (bounce) ou défaite (shake)
                        .scaleEffect(winScale)
                        .rotationEffect(.degrees(loseRotation))
                        .transition(.scale)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                Text("Qui est ce Pokémon ?")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Liste des options (5 propositions)
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        if option.lowercased() == target.name.lowercased() {
                            isCorrect = true
                            score += 1
                            // Animation de victoire : un petit bounce
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                                winScale = 1.2
                            }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.3).delay(0.3)) {
                                winScale = 1.0
                            }
                        } else {
                            isCorrect = false
                            // Animation de défaite : shake (rotation oscillante)
                            withAnimation(Animation.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                                loseRotation = 10
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                loseRotation = 0
                            }
                        }
                        withAnimation { showResult = true }
                    }) {
                        Text(option.capitalized)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .disabled(showResult)
                    .transition(.opacity)
                }
                
                if showResult, let correct = isCorrect {
                    Text(correct ? "Bravo, c'est correct !" : "Raté, c'était \(target.name.capitalized)")
                        .font(.headline)
                        .foregroundColor(correct ? .green : .red)
                        .transition(.opacity)
                }
            } else {
                ProgressView("Chargement du mini-jeu...")
            }
            
            Spacer()
            
            // Bouton "Rejouer" remonté
            Button("Rejouer") {
                resetGame()
            }
            .padding()
            
            // Score déplacé en bas
            Text("Score: \(score)")
                .font(.headline)
                .padding()
        }
        .padding()
        .background(Color(white: 0.9).ignoresSafeArea())
        .onAppear {
            startGame()
            // Animation idle de l'ombre : l'ellipse pulse
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                shadowScale = 0.8
            }
            // Animation idle du sprite : effet haut/bas (entre 5 et -5)
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                spriteIdleOffset = -5
            }
        }
    }
    
    private func startGame() {
        guard !pokemons.isEmpty else { return }
        targetPokemon = pokemons.randomElement()
        if let target = targetPokemon {
            var names = Set<String>()
            names.insert(target.name)
            while names.count < 5 {
                if let randomPokemon = pokemons.randomElement() {
                    names.insert(randomPokemon.name)
                }
            }
            options = Array(names).shuffled()
        }
        selectedOption = nil
        isCorrect = nil
        showResult = false
        // Réinitialise l'offset du sprite pour que l'animation se déclenche
        spriteIdleOffset = 5
        // Réinitialise les animations de victoire et défaite
        winScale = 1.0
        loseRotation = 0.0
    }
    
    private func resetGame() {
        startGame()
    }
}
