import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Autorisation de notification accordée.")
            } else {
                print("Autorisation refusée: \(error?.localizedDescription ?? "Erreur inconnue")")
            }
        }
    }
    
    func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Pokédex Daily"
        content.body = "Découvrez un Pokémon aléatoire aujourd'hui !"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Erreur lors de la planification: \(error.localizedDescription)")
            } else {
                print("Notification quotidienne planifiée")
            }
        }
    }
}
