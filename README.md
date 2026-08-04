# 🎓 LevelUp Tube

A **high-performance, distraction-free learning application** built with Flutter. Save videos, organize playlists, track watch progress, and resume where you left off — without ads, recommendations, or comments.

---

## ✨ Features

| Feature | Description |
|---|---|
| 📥 **Save Videos** | Paste any YouTube URL → metadata is fetched via YouTube Data API v3 |
| 🗂️ **Playlists** | Organize your saved videos into custom playlists for structured learning |
| ▶️ **Inline Player** | Distraction-free YouTube player — no ads, no recommendations, no comments |
| 📺 **Picture-in-Picture (PiP)** | Continue watching videos while navigating the app or using other apps |
| 📊 **Progress Tracking** | Auto-saves watch position. Resume exactly where you left off |
| 🔄 **Smart Resume** | Videos watched >95% restart from the beginning; others resume from saved position |
| 📋 **Clipboard Detection** | Copy a YouTube URL anywhere → open the app → instant "Add / Watch Now" prompt |
| 📱 **Fullscreen Mode** | Custom landscape fullscreen with smooth fade transition |
| 🌗 **Theme Toggle** | Switch between light, dark, and system theme |
| 📶 **Offline Alerts** | Toasts when internet drops or reconnects, so you know why YouTube buffers |
| 🔍 **Search** | Easily search through your saved library and playlists |
| 🚀 **Over-The-Air Updates** | Seamless app updates powered by Shorebird |

---

## 🏗️ Architecture

Built with a **Feature-Driven Architecture** utilizing an MVVM-inspired pattern with Cubits. The app is divided into distinct feature modules, ensuring high cohesion and low coupling.

### Folder Structure

```
lib/src/
├── core/
│   ├── config/        # Environment and app configuration
│   ├── di/            # GetIt dependency injection
│   ├── error/         # Exception & Failure hierarchy
│   ├── router/        # GoRouter setup
│   ├── services/      # Core services (Logging, Crashlytics)
│   ├── design_system/ # Design tokens (sizes, radius, shadows, colors, theme)
│   └── widgets/       # Reusable UI components
└── features/
    ├── library/       # Core video management
    ├── playlist/      # Playlist creation and management
    ├── pip/           # Picture-in-Picture functionality
    ├── clipboard/     # Clipboard URL detection
    └── ...            # Other independent feature modules
```

Inside each feature, the structure typically follows:
- `models/` - Data representations
- `repositories/` - Data access layer
- `services/` - Feature-specific business logic or external integrations
- `viewmodels/` - State management (Cubits)
- `views/` - UI components and pages

---

## 🛠️ Tech Stack

| Category | Package | Purpose |
|---|---|---|
| **State Management** | `flutter_bloc` | Predictable state management via Cubits |
| **Local Database** | `objectbox` | High-performance NoSQL with typed queries |
| **Backend & Analytics** | Firebase | Crashlytics, Analytics, Remote Config, and Storage |
| **Code Gen** | `freezed` | Immutable entities with `copyWith` & pattern matching |
| **DI** | `get_it` | Service locator with lazy singletons |
| **Routing** | `go_router` | Declarative navigation with route observer |
| **Video Player** | `youtube_player_iframe` | Distraction-free embedded player |
| **OTA Updates** | `shorebird` | Over-the-air hot updates |
| **Logging** | `talker_flutter` | Structured logging with in-app log viewer |
| **Image Caching** | `cached_network_image` | Thumbnail caching with shimmer |

---

## 🔑 Design Patterns

- **Feature-First Organization** — Code grouped by feature rather than layer
- **Repository Pattern** — Abstracts data sources (ObjectBox, Firebase)
- **Service Locator** — GetIt for dependency injection
- **Observer Pattern** — BLoC, TalkerBlocObserver
- **Singleton Services** — Global services initialized at startup

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.9.0`
- Dart SDK `>=3.9.0`

### Setup

```bash
# Clone the repo
git clone https://github.com/anshra1/grow_tube.git
cd grow_tube

# Install dependencies
flutter pub get

# Generate ObjectBox & Freezed code
dart run build_runner build --delete-conflicting-outputs

# Run the app (YouTube Data API v3 key required)
flutter run --dart-define=YOUTUBE_API_KEY=YOUR_KEY
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add your Android/iOS app and download config files
3. Replace `lib/firebase_options.dart` with your generated options
4. Place `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`

---

## 📄 License

This project is for personal learning purposes.
