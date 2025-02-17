import SwiftUI

struct CombatView: View {
    let playerPokemon: Pokemon
    @Environment(\.dismiss) var dismiss

    @State private var opponentPokemon: Pokemon?
    @State private var isLoadingOpponent: Bool = true
    @State private var battleResult: String? = nil
    @State private var isBattling: Bool = false

    // Animation states for attack offsets
    @State private var playerAttackOffset: CGFloat = 0
    @State private var opponentAttackOffset: CGFloat = 0

    // States for final explosion effect with "💥"
    @State private var playerImageScale: CGFloat = 1.0
    @State private var opponentImageScale: CGFloat = 1.0
    @State private var explosionEmojiOpacity: Double = 0.0
    @State private var explosionEmojiScale: CGFloat = 0.0

    // New state for idle bounce on the loser
    @State private var loserIdleOffset: CGFloat = 0

    // To know qui est le gagnant (true: player gagne, false: opponent gagne)
    @State private var winnerIsPlayerState: Bool? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoadingOpponent {
                    ProgressView("Chargement de l'adversaire...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                } else if let opponent = opponentPokemon {
                    // Affichage des deux Pokémon
                    HStack(spacing: 30) {
                        // Vue du Joueur (gauche)
                        VStack {
                            ZStack {
                                AsyncImage(url: URL(string: playerPokemon.imageURL)) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        // Si le joueur est perdant, ajouter le bounce idle
                                        .offset(x: playerAttackOffset + ((winnerIsPlayerState == false) ? loserIdleOffset : 0))
                                        .scaleEffect(playerImageScale)
                                        .rotationEffect(.degrees(playerAttackOffset == 0 ? 0 : 10))
                                } placeholder: {
                                    ProgressView()
                                }
                                // Explosion "💥" si le joueur perd
                                if let winner = winnerIsPlayerState, !winner {
                                    Text("💥")
                                        .font(.system(size: 50))
                                        .scaleEffect(explosionEmojiScale)
                                        .opacity(explosionEmojiOpacity)
                                }
                            }
                            Text(playerPokemon.name.capitalized)
                        }
                        
                        Text("VS")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // Vue de l'Adversaire (droite)
                        VStack {
                            ZStack {
                                AsyncImage(url: URL(string: opponent.imageURL)) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        // Si l'adversaire est perdant, ajouter le bounce idle
                                        .offset(x: opponentAttackOffset + ((winnerIsPlayerState == true) ? loserIdleOffset : 0))
                                        .scaleEffect(opponentImageScale)
                                        .rotationEffect(.degrees(opponentAttackOffset == 0 ? 0 : -10))
                                } placeholder: {
                                    ProgressView()
                                }
                                // Explosion "💥" si l'adversaire perd
                                if let winner = winnerIsPlayerState, winner {
                                    Text("💥")
                                        .font(.system(size: 50))
                                        .scaleEffect(explosionEmojiScale)
                                        .opacity(explosionEmojiOpacity)
                                }
                            }
                            Text(opponent.name.capitalized)
                        }
                    }
                    
                    if let result = battleResult {
                        Text(result)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(result.contains("gagné") ? .green : .red)
                            .padding()
                    }
                    
                    if !isBattling && battleResult == nil {
                        Button("Commencer le combat") {
                            simulateBattleAnimations()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    if battleResult != nil {
                        Button("Rejouer") {
                            resetBattle()
                            fetchOpponent()
                        }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                } else {
                    Text("Erreur lors du chargement de l'adversaire.")
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Mode Combat")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Terminer") { dismiss() }
                }
            }
            .onAppear { fetchOpponent() }
        }
    }

    // MARK: - Fetch Opponent
    private func fetchOpponent() {
        isLoadingOpponent = true
        battleResult = nil
        resetBattleAnimations()
        Task {
            let randomId: Int = {
                var id = Int.random(in: 1...151)
                if id == playerPokemon.id && 151 > 1 {
                    id = (id % 151) + 1
                }
                return id
            }()
            do {
                let opponent = try await PokemonService.shared.fetchPokemonById(randomId)
                DispatchQueue.main.async {
                    opponentPokemon = opponent
                    isLoadingOpponent = false
                }
            } catch {
                print("Error fetching opponent: \(error)")
                DispatchQueue.main.async { isLoadingOpponent = false }
            }
        }
    }

    // MARK: - Simulate Attack Rounds and Final Explosion
    private func simulateBattleAnimations() {
        guard let opponent = opponentPokemon else { return }
        isBattling = true
        resetBattleAnimations()
        
        let playerAvg = averageStat(for: playerPokemon)
        let opponentAvg = averageStat(for: opponent)
        let diff = abs(playerAvg - opponentAvg)
        let winnerIsPlayer = playerAvg >= opponentAvg
        winnerIsPlayerState = winnerIsPlayer
        
        // Calcul du nombre de rounds entre 3 et 8, ajusté pour que le gagnant attaque en dernier.
        let baseRounds = min(max(3, Int(diff / 10) + 3), 8)
        var rounds = baseRounds
        if winnerIsPlayer {
            if rounds % 2 == 0 { rounds = rounds < 8 ? rounds + 1 : rounds - 1 }
        } else {
            if rounds % 2 == 1 { rounds = rounds < 8 ? rounds + 1 : rounds - 1 }
        }
        
        func performRound(round: Int) {
            let isPlayerTurn = (round % 2 == 1)
            if isPlayerTurn {
                withAnimation(Animation.interpolatingSpring(stiffness: 350, damping: 15)) {
                    playerAttackOffset = 50
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(Animation.interpolatingSpring(stiffness: 350, damping: 15)) {
                        playerAttackOffset = 0
                    }
                    if round < rounds {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            performRound(round: round + 1)
                        }
                    } else {
                        finalizeBattle(winnerIsPlayer: winnerIsPlayer)
                    }
                }
            } else {
                withAnimation(Animation.interpolatingSpring(stiffness: 350, damping: 15)) {
                    opponentAttackOffset = -50
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(Animation.interpolatingSpring(stiffness: 350, damping: 15)) {
                        opponentAttackOffset = 0
                    }
                    if round < rounds {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            performRound(round: round + 1)
                        }
                    } else {
                        finalizeBattle(winnerIsPlayer: winnerIsPlayer)
                    }
                }
            }
        }
        performRound(round: 1)
    }
    
    // MARK: - Final Explosion & Idle Animation
    private func finalizeBattle(winnerIsPlayer: Bool) {
        // L'explosion "💥" apparaît juste avant le déplacement final.
        withAnimation(Animation.easeInOut(duration: 0.5).delay(0.3)) {
            explosionEmojiScale = 2.0
            explosionEmojiOpacity = 1.0
        }
        
        // Après l'explosion, on expulse le perdant de manière modérée et on lance une animation idle.
        if winnerIsPlayer {
            // Le joueur gagne : l'adversaire (à droite) se décale vers la droite (mais pas hors de l'écran)
            withAnimation(Animation.easeInOut(duration: 0.5).delay(0.8)) {
                opponentAttackOffset = 100
                opponentImageScale = 0.7
            }
            // Lancer une animation idle (bounce léger) sur le perdant
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).delay(0.8)) {
                loserIdleOffset = 5
            }
            // Mettre en valeur le gagnant (centre)
            withAnimation(Animation.easeInOut(duration: 0.5).delay(0.8)) {
                playerImageScale = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(Animation.easeOut(duration: 0.5)) {
                    explosionEmojiOpacity = 0.0
                }
                battleResult = "\(playerPokemon.name.capitalized) a gagné !"
                isBattling = false
            }
        } else {
            // L'adversaire gagne : le joueur (à gauche) se décale vers la gauche
            withAnimation(Animation.easeInOut(duration: 0.5).delay(0.8)) {
                playerAttackOffset = -100
                playerImageScale = 0.7
            }
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).delay(0.8)) {
                loserIdleOffset = 5
            }
            withAnimation(Animation.easeInOut(duration: 0.5).delay(0.8)) {
                opponentImageScale = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(Animation.easeOut(duration: 0.5)) {
                    explosionEmojiOpacity = 0.0
                }
                battleResult = "\(playerPokemon.name.capitalized) a perdu..."
                isBattling = false
            }
        }
    }
    
    private func resetBattleAnimations() {
        playerAttackOffset = 0
        opponentAttackOffset = 0
        playerImageScale = 1.0
        opponentImageScale = 1.0
        explosionEmojiOpacity = 0.0
        explosionEmojiScale = 0.0
        loserIdleOffset = 0
        winnerIsPlayerState = nil
    }
    
    private func resetBattle() {
        battleResult = nil
        isBattling = false
        resetBattleAnimations()
    }
    
    /// Calcule la moyenne des stats d'un Pokémon.
    private func averageStat(for pokemon: Pokemon) -> Double {
        guard !pokemon.stats.isEmpty else { return 0 }
        let total = pokemon.stats.reduce(0) { $0 + Double($1.baseStat) }
        return total / Double(pokemon.stats.count)
    }
}

#Preview {
    CombatView(playerPokemon: Pokemon(
        id: 1,
        name: "Bulbasaur",
        sprites: Sprites(frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"),
        types: [PokemonTypeWrapper(type: PokemonType(name: "grass"))],
        stats: [StatWrapper(baseStat: 45, stat: Stat(name: "hp"))]
    ))
}
