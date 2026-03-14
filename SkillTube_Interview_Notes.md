# SkillTube — Interview Preparation Notes

## 1. Elevator Pitch (30 seconds)

> **SkillTube** is a **distraction-free YouTube learning app** built with Flutter. Users paste a YouTube URL, the app fetches metadata (title, thumbnail, duration) using `youtube_explode_dart`, saves it to a local **ObjectBox** database, and plays the video inline using `youtube_player_iframe` — all without ads, recommendations, or comments. It tracks watch progress automatically and resumes where you left off.

---

## 2. Architecture Overview

### Clean Architecture (3 Layers)

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

**Key Principle**: Dependencies point **inward**. Domain knows nothing about Flutter, ObjectBox, or any package. Data layer depends on Domain interfaces. Presentation depends on Domain entities.

### Folder Structure
```
lib/src/
├── core/           ← shared utilities, DI, routing, error, design system, widgets
│   ├── common/     ← typedef.dart (ResultFuture), usecase.dart (base classes)
│   ├── di/         ← injection_container.dart (GetIt setup)
│   ├── error/      ← exception.dart, failure.dart
│   ├── router/     ← app_router.dart (GoRouter)
│   ├── services/   ← clipboard_service.dart, logging/ (AppLogger facade)
│   ├── mixins/     ← clipboard_monitor_mixin.dart
│   ├── design_system/ ← tokens (sizes, radius, shadows, colors, theme)
│   └── widgets/    ← reusable UI components (atomic design buttons)
└── features/
    └── library/
        ├── data/        ← models, datasources, repository impl
        ├── domain/      ← entities, repository interface, use cases
        └── presentation/← bloc, pages, widgets
```

---

## 3. Tech Stack — Why Each Choice

| Package | Why I Chose It |
|---|---|
| **flutter_bloc** | Predictable state management. Sealed events/states give compile-time safety. Built-in `BlocObserver` for debugging. |
| **ObjectBox** | Fastest NoSQL DB for Flutter (~10x faster than Hive). Auto-generates IDs, supports queries with ordering, unique constraints. No SQL boilerplate. |
| **fpdart (Either)** | Functional error handling. `Either<Failure, Success>` forces callers to handle both cases. No uncaught exceptions leak to UI. |
| **freezed** | Immutable data classes with `copyWith`, equality, and pattern matching. Used for the `Video` entity. |
| **equatable** | Value equality for BLoC states/events and `Failure` classes. Prevents unnecessary rebuilds. |
| **get_it** | Simple service locator for DI. Lazy singletons for datasources/repos, `registerFactory` for BLoC (new instance per widget). |
| **go_router** | Declarative routing with `TalkerRouteObserver` for automatic navigation logging. |
| **youtube_explode_dart** | Fetches video metadata (title, thumbnail, duration, channel) without a YouTube API key. No quota limits. |
| **youtube_player_iframe** | Embeds YouTube player via WebView. Distraction-free — no ads, recommendations, comments. |
| **talker** | Structured logging with levels (debug/info/warning/error). In-app log viewer via `TalkerFlutter`. |
| **firebase_crashlytics** | Production crash reporting. Catches both sync (`FlutterError.onError`) and async (`PlatformDispatcher.onError`) errors. |
| **cached_network_image** | Caches video thumbnails locally. Shows shimmer placeholder while loading. |

---

## 4. Error Handling Strategy (Two-Layer Pattern)

### Layer 1: Exceptions (Data Layer → thrown)
```dart
abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;
}
// Subtypes: ServerException, DatabaseException, VideoException,
//           AuthException, CacheException, ParsingException, StorageException
```

### Layer 2: Failures (Domain Layer → returned via Either)
```dart
abstract class Failure extends Equatable {
  final String message;
  final String? title;  // "Server Error", "Video Error" etc.
  final String? code;
}
// Subtypes: ServerFailure, CacheFailure, VideoFailure,
//           ConnectionFailure, AuthFailure, UnknownFailure
```

### Flow:
```
DataSource throws VideoException("duplicate")
       ↓
Repository catches it → returns Left(VideoFailure(message, code))
       ↓
BLoC calls result.fold(onFailure, onSuccess)
       ↓
UI shows toast with failure.message
```

### Type alias:
```dart
typedef ResultFuture<T> = Future<Either<Failure, T>>;
```

---

## 5. Dependency Injection (GetIt)

```dart
// Externals (singleton — one instance forever)
sl.registerLazySingleton(() => store);       // ObjectBox Store
sl.registerLazySingleton(YoutubeExplode.new); // YouTube client

// DataSources (lazy singleton — created once when first requested)
sl.registerLazySingleton<VideoLocalDataSource>(() => VideoLocalDataSourceImpl(sl()));
sl.registerLazySingleton<VideoRemoteDataSource>(() => VideoRemoteDataSourceImpl(sl()));

// Repository (lazy singleton — same instance shared)
sl.registerLazySingleton<VideoRepository>(() => VideoRepositoryImpl(...));

// UseCases (lazy singleton — stateless, reusable)
sl.registerLazySingleton(() => GetAllVideos(sl()));
sl.registerLazySingleton(() => AddVideo(sl()));

// BLoC (factory — NEW instance every time, prevents stale state)
sl.registerFactory(() => LibraryBloc(getAllVideos: sl(), ...));
```

**Interview Tip**: "I use `registerFactory` for BLoC because each widget tree needs a fresh instance. Using a singleton BLoC would share state across unrelated screens."

---

## 6. Domain Layer — Entity & Use Cases

### Video Entity (freezed — immutable)
```dart
@freezed
abstract class Video with _$Video {
  const factory Video({
    required int id,
    required String youtubeId,
    required String title,
    required String channelName,
    required String thumbnailUrl,
    required int durationSeconds,
    required int lastWatchedPositionSeconds,
    required DateTime addedAt,
    DateTime? lastPlayedAt,
  }) = _Video;

  // Computed properties:
  double get progressPercent => durationSeconds > 0
      ? lastWatchedPositionSeconds / durationSeconds : 0.0;
  bool get isCompleted => progressPercent > 0.95;  // >95% = finished
  bool get hasBeenPlayed => lastPlayedAt != null;
}
```

### Use Case Pattern (Single Responsibility)
```dart
abstract class FutureUseCaseWithParams<T, Params> {
  ResultFuture<T> call(Params params);
}
```
**6 Use Cases**: `GetAllVideos`, `GetVideo`, `GetLastPlayedVideo`, `AddVideo`, `DeleteVideo`, `UpdateVideoProgress`

Each use case is a **single callable class** that delegates to the repository.

---

## 7. Data Layer — Model & DataSources

### VideoModel (ObjectBox entity)
- `@Entity()` annotation for ObjectBox
- `@Id()` auto-increment, `@Unique()` on `youtubeId`
- `@Property(type: PropertyType.dateNano)` for DateTime precision
- Has `toEntity()` and `fromEntity()` mappers (Model ↔ Entity)

### VideoLocalDataSource (ObjectBox)
- **getAllVideos**: `ORDER BY addedAt DESC` (newest first)
- **getLastPlayedVideo**: `WHERE lastPlayedAt != null ORDER BY lastPlayedAt DESC LIMIT 1`, fallback: `ORDER BY addedAt DESC LIMIT 1`
- **addVideo**: Checks duplicate via `WHERE youtubeId == video.youtubeId` before insert
- **updateVideoProgress**: Updates position + sets `lastPlayedAt = DateTime.now()`

### VideoRemoteDataSource (YouTube)
- Uses `youtube_explode_dart` to parse URL → fetch metadata
- Maps errors: invalid URL → `VideoException('invalidUrl')`, private video → `videoUnavailable`, network error → `offline`
- Returns `VideoModel(id: 0)` ready for ObjectBox insertion

### VideoRepositoryImpl
- Catches `DatabaseException` → returns `CacheFailure`
- Catches `VideoException` → returns `VideoFailure`
- Catches unknown → returns `UnknownFailure`
- **addVideo flow**: Remote fetch → Local save → return entity

---

## 8. BLoC (State Management)

### Events (sealed class)
| Event | Trigger |
|---|---|
| `LibraryInitializedEvent` | App launch |
| `LibraryVideoAddedEvent(url)` | User submits URL manually |
| `LibraryVideoDeletedEvent(id)` | User long-presses → confirms delete |
| `LibraryVideoProgressUpdatedEvent(youtubeId, positionSeconds)` | Heartbeat timer (every 60s) |
| `LibraryVideoAddedAndPlayRequested(url)` | Clipboard prompt "Watch Now" |
| `LibraryVideoSelectedEvent(video)` | User taps a video card |

### States (sealed class)
| State | When |
|---|---|
| `LibraryInitialState` | Before first load |
| `LibraryLoadingState` | During add/delete operations |
| `LibraryEmptyState` | No videos in library |
| `LibraryVideoLoadedState(libraryVideos, lastPlayVideo)` | Videos loaded successfully |
| `LibraryFailureState(message)` | Error occurred |

### Key BLoC Logic: `_refreshLibrary()`
1. Fetch all videos via `_getAllVideos()`
2. If empty → emit `LibraryEmptyState`
3. If `_selectedHeroId` is set (user explicitly picked a video), keep that as hero
4. Otherwise, call `_getLastPlayedVideo()` for the hero
5. Emit `LibraryVideoLoadedState`

**Why `_selectedHeroId`?** — Prevents the hero video from "jumping" when the heartbeat saves progress. Without it, every 60-second save would call `_refreshLibrary`, which would re-query `getLastPlayedVideo`, potentially changing the hero.

---

## 9. Presentation Layer (UI)

### Dashboard Page
- Uses `BlocBuilder` with `buildWhen` for **selective rebuilds** (only rebuilds on specific state changes)
- Uses **Dart 3 switch expressions** for clean state → widget mapping
- `BlocListener` for error toasts (fires once, doesn't rebuild)
- Shimmer loading placeholder during initial load

### Smart Clipboard Feature
1. `ClipboardMonitorMixin` listens to `AppLifecycleState.resumed`
2. On resume → reads clipboard via `ClipboardService`
3. If it's a new YouTube URL → shows `ClipboardVideoPrompt` toast
4. User can tap "Add to Library" or "Watch Now"
5. Deduplication: `ClipboardService._lastProcessedUrl` + `_promptedVideoIds` set

### Video Player (`DashboardVideoPlayer`)
- **Initialization**: `cueVideoById()` (shows thumbnail, NO auto-play)
- **Video switch**: `didUpdateWidget` detects new `youtubeId` → saves old progress → `loadVideoById()` (auto-plays)
- **Resume logic**: If `isCompleted` (>95%), start from 0. Otherwise, resume from `lastWatchedPositionSeconds`.
- **Progress heartbeat**: `Timer.periodic(60s)` → save current position
- **Fullscreen**: Custom implementation with `OverlayPortal` + `SystemChrome.setPreferredOrientations` + fade animation for smooth transitions
- **Cleanup**: `dispose()` saves final progress, cancels timer, closes controller

### Video Card (`DashboardVideoCard`)
- `CachedNetworkImage` with shimmer placeholder
- Duration overlay badge
- Progress bar with percentage
- Tap → `LibraryVideoSelectedEvent`
- Long press → `DeleteVideoDialog`

---

## 10. Logging & Crash Reporting

### Multi-Backend Logging (Strategy Pattern)
```dart
abstract class LoggingService {
  void log(LogLevel level, String message, {Object? error, StackTrace?});
  void setUserIdentifier(String userId);
  void setCustomKey(String key, String value);
}

class AppLogger {
  final List<LoggingService> _services;  // Fan-out to all backends
  void debug(msg) => _log(LogLevel.debug, msg);
  void error(msg) => _log(LogLevel.error, msg);
}
```
Currently uses `TalkerLoggingService`. Can add Crashlytics or Analytics backends without changing any calling code (Open/Closed Principle).

### Crashlytics Setup (main.dart)
```dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```
- **Sync errors**: Widget build failures, layout overflows
- **Async errors**: Unhandled Futures, Isolate errors

### BLoC Observer
```dart
Bloc.observer = TalkerBlocObserver(talker: talker);
```
Logs every BLoC event, state change, and transition automatically.

---

## 11. Design System

- **ThemeExtension**: Custom `AppColorsExtension` for semantic colors (success, warning, textPrimary, textSecondary) with `lerp` for smooth transitions
- **Design Tokens**: `AppSizes`, `AppRadius`, `AppShadows`, `AppSpacing`, `AppDurations`, `AppTypography`
- **Atomic Design Buttons**: 10+ button variants (Primary, Secondary, Outline, Ghost, Link, Social, Destructive, Icon)
- **Material 3**: `ColorScheme.fromSeed()` with dark mode, `useMaterial3: true`
- **Context Extensions**: `context.colorScheme`, `context.textTheme` for cleaner widget code

---

## 12. Likely Interview Questions & Answers

### Q: "Walk me through what happens when a user pastes a YouTube URL."
**A**: 
1. User taps FAB → `AddVideoBottomSheet` opens
2. User enters URL → `LibraryVideoAddedEvent(url)` dispatched to BLoC
3. BLoC calls `_addVideo(url)` use case → delegates to `VideoRepositoryImpl.addVideo()`
4. Repo calls `RemoteDataSource.fetchVideoDetails(url)` → `youtube_explode_dart` parses URL, fetches metadata
5. Repo calls `LocalDataSource.addVideo(model)` → ObjectBox saves with duplicate check
6. Repo returns `Right(video.toEntity())` → BLoC calls `_refreshLibrary()` → emits `LibraryVideoLoadedState`
7. `BlocBuilder` rebuilds the video list and hero player

### Q: "How do you handle errors?"
**A**: Two-layer pattern. Data layer **throws** typed exceptions (`VideoException`, `DatabaseException`). Repository **catches** them and returns `Either<Failure, T>` using `fpdart`. BLoC uses `result.fold()` to either emit error state or success state. The UI uses `BlocListener` to show toast on `LibraryFailureState`. Exceptions never leak to the UI.

### Q: "Why ObjectBox over Hive or SQLite?"
**A**: Performance and query capability. ObjectBox is roughly 10x faster than Hive for reads. Unlike Hive, ObjectBox supports typed queries (`WHERE`, `ORDER BY`, `LIMIT`), which I need for `getLastPlayedVideo` (query by `lastPlayedAt DESC`). Unlike SQLite, there's no SQL string boilerplate — just Dart annotations.

### Q: "How does the video progress tracking work?"
**A**: A `Timer.periodic(60 seconds)` heartbeat reads `controller.currentTime` and dispatches `LibraryVideoProgressUpdatedEvent`. The BLoC calls `UpdateVideoProgress`, which writes `lastWatchedPositionSeconds` and `lastPlayedAt = DateTime.now()` to ObjectBox. On video switch (`didUpdateWidget`), the old video's progress is saved immediately. On dispose (leaving page), final progress is saved. Resume uses `isCompleted` (>95%) to decide: start from 0 or resume from saved position.

### Q: "How does the clipboard detection work?"
**A**: I built a `ClipboardMonitorMixin` that uses `WidgetsBindingObserver` to listen for `AppLifecycleState.resumed`. When the user returns to the app, it reads the clipboard, runs a regex to extract a YouTube video ID, checks it hasn't been processed already (`_lastProcessedUrl` + `_promptedVideoIds`), and shows a sliding toast with "Add to Library" / "Watch Now" options.

### Q: "Explain your fullscreen implementation."
**A**: I couldn't use the default YouTube fullscreen because `youtube_player_iframe` doesn't support it natively on all platforms. So I built a custom solution using `OverlayPortal` — when the user taps fullscreen, the player is "beamed" to a top-level overlay, the device rotates to landscape via `SystemChrome.setPreferredOrientations`, and a fade animation covers the rotation transition so the user doesn't see the player stretching. Back button (`PopScope`) handles exit.

### Q: "Why `sealed class` for events and states?"
**A**: `sealed class` provides **exhaustiveness checking** in Dart 3 switch expressions. The compiler ensures I handle every possible state in the UI. If I add a new state, the IDE shows errors everywhere I forgot to handle it. This gives compile-time safety.

### Q: "What design patterns do you use?"
**A**: 
- **Clean Architecture** (3 layers, dependency rule)
- **Repository Pattern** (abstracts data sources behind an interface)
- **Use Case / Interactor Pattern** (single-purpose callable classes)
- **Service Locator** (GetIt for DI)
- **Strategy Pattern** (AppLogger with pluggable LoggingService backends)
- **Observer Pattern** (BLoC, WidgetsBindingObserver)
- **Singleton Pattern** (ClipboardService)
- **Mixin-based composition** (ClipboardMonitorMixin)

### Q: "How would you add Firebase sync / multi-device support?"
**A**: I would add a `VideoRemoteRepository` (Firestore) and create a `SyncService` that compares local ObjectBox timestamps with Firestore. On app launch, pull remote changes. On progress save, push to Firestore if played > 30 seconds (to reduce writes). The existing Repository interface wouldn't change — I'd update `VideoRepositoryImpl` to coordinate both data sources.

### Q: "How do you ensure the video player doesn't rebuild unnecessarily?"
**A**: Three strategies: (1) `BlocBuilder.buildWhen` — only rebuild when state is `Loaded`, `Initial`, or `Empty`. (2) `Equatable` on all states — BLoC skips emission if the new state equals the old one. (3) `_selectedHeroId` — prevents the hero video from changing during heartbeat refreshes.
