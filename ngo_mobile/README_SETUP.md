# 📱 NGO Agent Mobile App - Flutter

Une application mobile **Terrain First** pour gérer les activités de terrain des ONG.  
Agent mobile = dépenses, rapports d'impact, et synchronisation offline.

## 🎯 Fonctionnalités Implémentées (Phase 1)

### 🔐 Authentification
- ✅ Connexion par email + mot de passe (JWT)
- ✅ Stockage sécurisé du token (Hive)
- ✅ Persistance de session
- ✅ Auto-logout
- ✅ SplashScreen avec vérification d'authentification
- ✅ Profil utilisateur

### 🏠 Dashboard
- ✅ Vue d'ensemble des projets, dépenses, rapports
- ✅ Accès rapide aux actions principales
- ✅ Indicateur de synchronisation
- ✅ Liste des 3 derniers projets

### 📁 Gestion des Projets
- ✅ Liste des projets assignés
- ✅ Recherche/filtre par nom ou localisation
- ✅ Détails complets (description, dates, budget, donateurs)
- ✅ Statut du projet

### 💰 Gestion des Dépenses
- ✅ Liste des dépenses
- ✅ Formulaire d'ajout avec sélection de projet
- ✅ Détails des dépenses
- ✅ Support des champs : montant, description, date, catégorie
- ✅ Prêt pour photos et GPS

### 📊 Rapports d'Impact
- ✅ Liste des rapports
- ✅ Détails complets (titre, description, bénéficiaires, activités)
- ✅ Structure préparée pour photos et GPS

### 🎨 UX/UI
- ✅ Thème professionnel NGO (vert + rouge)
- ✅ Responsive design
- ✅ Icônes intuitives
- ✅ Gradient et cards élégantes
- ✅ Indicateurs de statut visuels

## 📊 Architecture

```
lib/
├── core/              # Constants, theme, colors
├── models/            # Data classes (Project, Expense, Report, User)
├── providers/         # State management (Provider)
│   ├── auth_provider.dart
│   ├── project_provider.dart
│   ├── expense_provider.dart
│   └── report_provider.dart
├── repositories/      # Data layer (API calls)
│   ├── project_repository.dart
│   ├── expense_repository.dart
│   └── report_repository.dart
├── services/          # External services
│   ├── auth_service.dart
│   ├── api_service.dart
│   └── storage_service.dart (Hive)
└── screens/           # UI Screens
    ├── auth/          # Login, Profile, Splash
    ├── dashboard/     # Home screen
    ├── projects/      # Project list & detail
    ├── expenses/      # Expense list & detail
    └── reports/       # Report list & detail
```

## 🚀 Démarrage Local

### Prérequis
- Flutter 3.10+ installé
- Dart 3.1+
- Android Studio / Xcode (selon la plateforme)
- Backend NGO API en cours d'exécution

### Installation

```bash
# Cloner le repo
git clone <url>
cd NGO_agent-mobile-app

# Installer les dépendances
flutter pub get

# (Optionnel) Générer les fichiers Hive
flutter pub run build_runner build

# Lancer sur émulateur/device
flutter run

# Lancer en mode release
flutter run --release
```

### Configuration du Backend

Modifier `lib/core/constants.dart` :

```dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android Emulator
  // ou 'http://127.0.0.1:3000' pour iOS Emulator
  // ou 'http://<IP_LOCALE>:3000' pour device physique
  
  static const String login = '/auth/login';
  static const String projects = '/projects';
}
```

### Identifiants Démo

Email: `agent@ngo.com`  
Password: `password123`

## 📝 Routes Disponibles

| Route | Screen | Rôle |
|-------|--------|------|
| `/splash` | SplashScreen | Vérification auth |
| `/login` | LoginScreen | Connexion |
| `/` | DashboardScreen | Accueil |
| `/profile` | ProfileScreen | Profil utilisateur |
| `/projects` | ProjectListScreen | Liste projets |
| `/expenses` | ExpenseListScreen | Liste dépenses |
| `/reports` | ImpactReportListScreen | Liste rapports |
| `/add-expense` | AddExpenseScreen | Ajouter dépense |
| `/add-report` | AddImpactReportScreen | Ajouter rapport |

## 🔧 Dépendances Principales

```yaml
provider: ^6.1.5          # State management
http: ^1.6.0              # API calls
jwt_decode: ^0.3.1        # JWT parsing
hive: ^2.2.3              # Local storage
hive_flutter: ^1.1.0      # Flutter integration
image_picker: ^1.0.0      # Camera & gallery
geolocator: ^9.0.2        # GPS
intl: ^0.19.0             # Internationalization
connectivity_plus: ^5.0.0 # Network detection
```

## 🔄 Authentification (JWT)

1. **Login** → Backend retourne `access_token` (JWT)
2. **Storage** → Token sauvegardé dans Hive
3. **Verification** → Token validé au redémarrage
4. **Auto-logout** → Si token expiré
5. **Header** → Token envoyé dans `Authorization: Bearer <token>`

## 📦 Offline First (Phase 2)

La structure est prête pour :
- Hive local pour cache
- Queue d'upload des dépenses/rapports
- Sync automatique au retour du réseau
- Indicateur visuel de sync

## 🎥 Caméra & GPS (Phase 2)

Structures préparées pour :
- `ImagePicker` → Prendre photos / galerie
- `Geolocator` → Capture GPS automatique
- Compression des images
- Upload avec métadonnées

## 🔔 Notifications (Phase 3)

À implémenter :
- Dépense approuvée/rejetée
- Nouveau projet assigné
- Sync réussie
- In-app + badges + push (Firebase)

## 🔒 Sécurité

- ✅ JWT tokens
- ✅ Token storage sécurisé (Hive)
- ✅ API headers avec Bearer token
- ✅ Validation des données
- 🔜 Biométrie (Phase 2)
- 🔜 PIN optionnel (Phase 2)

## 🌍 Multi-langue (Phase 2)

Structure prête pour intl :
- Français (FR)
- Anglais (EN)

## 📱 Build & Distribution

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ipa --release

# Web (optionnel)
flutter build web --release
```

## 📞 Support & Contact

- **Backend Docs**: Voir ARCHITECTURE.md du backend
- **Issues**: Ouvrir une issue sur le repo
- **Discord**: #ngo-app-dev

## 📄 License

MIT - NGO Project 2026
