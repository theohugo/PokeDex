import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isLoading: Bool
    @State private var selectedLimit: Int = 150  // **Choix par défaut**
    var onRefresh: (Int) -> Void

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    // **Animation de chargement**
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(2)
                        Text("Chargement...")
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    Form {
                        Section(header: Text("Paramètres du Pokédex")) {
                            Picker("Nombre de Pokémon", selection: $selectedLimit) {
                                Text("150").tag(150)
                                Text("500").tag(500)
                                Text("1000").tag(1000)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }
            }
            .navigationTitle("Paramètres")
            .toolbar {
                if !isLoading {
                    // **Bouton Rafraîchir**
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Rafraîchir") {
                            onRefresh(selectedLimit)
                        }
                    }
                    // **Bouton Annuler**
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onChange(of: isLoading) { newValue in
            if !newValue { dismiss() }
        }
    }
}
