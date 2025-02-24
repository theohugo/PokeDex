README - Application Swift Pokemon

Fonctionnalités principales

Récupération des données API et affichage avec cache local
 •    Les données des Pokémon sont récupérées depuis une API REST : https://pokeapi.co/api/v2.
 •    Utilisation de URLSession pour les requêtes réseau asynchrones.
 •    Mise en cache locale avec CoreData pour stocker les Pokémon et éviter des appels API répétés.
 •    Gestion de l’état hors ligne : les données chargées restent accessibles sans connexion Internet.
 
Navigation et détails d’un Pokémon avec CoreData
 •    Vue détaillée d’un Pokémon avec ses statistiques, son type et une illustration.
 •    Utilisation de CoreData pour stocker les favoris et éviter un rechargement inutile.
 
Recherche, filtrage et tri avancés
 •    Filtrage des Pokémon par type, points de combat et favoris et par noms.
 •    Interface fluide avec des animations.
 
Animations, interactions et mode combat
 •    Utilisation de SwiftUI et UIKit pour des animations fluides.
 •    Effets interactifs sur les boutons et transitions d’écran.
 •    Mode combat : sélection d’un Pokémon, affichage des attaques et animations de combat.
 
Notifications push et personnalisation avancée
 •    Intégration des notifications push avec UserNotifications.

Technologies utilisées
    •    Swift
    •    UIKit & SwiftUI pour l’interface utilisateur
    •    URLSession pour les requêtes API
    •    CoreData pour la persistance des données
    •    UserNotifications pour les notifications
    
Bonus
    •    Sombre / Clair
    •    Guess Pokemon minijeu

Auteur
RAGUIN Hugo, BABEL Mickael
