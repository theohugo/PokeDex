import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isLoading: Bool
    @State private var newLimitText: String = ""
    var onRefresh: (Int) -> Void

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    // **Loading animation view**
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
                            TextField("Nombre de Pokémon", text: $newLimitText)
                                .keyboardType(.numberPad)
                        }
                    }
                }
            }
            .navigationTitle("Paramètres")
            .toolbar {
                if !isLoading {
                    // **Refresh button**
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Rafraîchir") {
                            if let newLimit = Int(newLimitText), newLimit > 0 {
                                onRefresh(newLimit)
                            }
                        }
                    }
                    // **Cancel button**
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onChange(of: isLoading) { newValue in
            // Dismiss the modal when loading is finished
            if !newValue {
                dismiss()
            }
        }
    }
}
