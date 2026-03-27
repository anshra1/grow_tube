# 🎓 GrowTube

A **distraction-free YouTube learning app** built with Flutter. Save videos, track watch progress, and resume where you left off — without ads, recommendations, or comments.

---

## ✨ Features

| Feature | Description |
|---|---|
| 📥 **Save Videos** | Paste any YouTube URL → metadata (title, thumbnail, duration, channel) is fetched automatically |
| ▶️ **Inline Player** | Distraction-free YouTube player — no ads, no recommendations, no comments |
| 📊 **Progress Tracking** | Auto-saves watch position every 60 seconds. Resume exactly where you left off |
| 🔄 **Smart Resume** | Videos watched >95% restart from the beginning; others resume from saved position |
| 📋 **Clipboard Detection** | Copy a YouTube URL anywhere → open the app → instant "Add / Watch Now" prompt |
| 📱 **Fullscreen Mode** | Custom landscape fullscreen with smooth fade transition |
| 🗑️ **Library Management** | Long-press to delete. Tap to play. Hero video player shows your last watched video |

---

## 🏗️ Architecture

Built with **Clean Architecture** — 3 layers with strict dependency rules:

```
┌──────────────────────────────────────────────────┐
│              PRESENTATION LAYER                  │
│  BLoC (Events → States) + Flutter Widgets        │
├──────────────────────────────────────────────────┤
│                DOMAIN LAYER                      │
│  Entities (pure Dart) + Use Cases + Repo Iface   │
├──────────────────────────────────────────────────┤
│                 DATA LAYER                       │
│  Models (ObjectBox) + DataSources + Repo Impl    │
└──────────────────────────────────────────────────┘
```

### Folder Structure

```
lib/src/
├── core/
│   ├── common/        # ResultFuture typedef, UseCase base classes
│   ├── di/            # GetIt dependency injection
│   ├── error/         # Exception & Failure hierarchy
│   ├── router/        # GoRouter setup
│   ├── services/      # ClipboardService, Logging (AppLogger facade)
│   ├── mixins/        # ClipboardMonitorMixin
│   ├── design_system/ # Design tokens (sizes, radius, shadows, colors, theme)
│   └── widgets/       # Reusable UI components (Atomic Design buttons)
└── features/
    └── library/
        ├── data/          # VideoModel, DataSources (local + remote), Repo impl
        ├── domain/        # Video entity (freezed), Repo interface, 6 Use Cases
        └── presentation/  # LibraryBloc, Dashboard page, 8 widgets
```

---

## 🛠️ Tech Stack

| Category | Package | Purpose |
|---|---|---|
| **State Management** | `flutter_bloc` | Predictable state with sealed events/states |
| **Local Database** | `objectbox` | High-performance NoSQL with typed queries |
| **Error Handling** | `fpdart` | Functional `Either<Failure, T>` — no uncaught exceptions |
| **Code Gen** | `freezed` | Immutable entities with `copyWith` & pattern matching |
| **Equality** | `equatable` | Value equality for BLoC states & Failure classes |
| **DI** | `get_it` | Service locator with lazy singletons |
| **Routing** | `go_router` | Declarative navigation with route observer |
| **Video Metadata** | `youtube_explode_dart` | Fetches metadata without API keys |
| **Video Player** | `youtube_player_iframe` | Distraction-free embedded player |
| **Logging** | `talker` | Structured logging with in-app log viewer |
| **Crash Reporting** | `firebase_crashlytics` | Production error tracking |
| **Image Caching** | `cached_network_image` | Thumbnail caching with shimmer |

---

## 🔑 Design Patterns

- **Clean Architecture** — 3 layers, dependency inversion
- **Repository Pattern** — abstracts local/remote data sources
- **Use Case Pattern** — single-purpose callable classes
- **Service Locator** — GetIt for dependency injection
- **Strategy Pattern** — pluggable logging backends (AppLogger)
- **Observer Pattern** — BLoC, WidgetsBindingObserver
- **Mixin Composition** — ClipboardMonitorMixin for lifecycle-aware clipboard detection

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

# Run the app (YouTube API key required)
flutter run --dart-define=YOUTUBE_API_KEY=YOUR_KEY
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add your Android/iOS app and download config files
3. Replace `lib/firebase_options.dart` with your generated options

---

## 📐 Error Handling

Two-layer pattern ensures exceptions never leak to the UI:

```
DataSource throws VideoException("duplicate")
       ↓
Repository catches → returns Left(VideoFailure(message, code))
       ↓
BLoC calls result.fold(onFailure, onSuccess)
       ↓
UI shows toast via BlocListener
```

```dart
// Type alias for clean signatures
typedef ResultFuture<T> = Future<Either<Failure, T>>;
```

---

## 📄 License

This project is for personal learning purposes.
