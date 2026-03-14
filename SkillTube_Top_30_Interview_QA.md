# SkillTube — Top 30 Interview Questions & Answers

---

## 🎯 PROJECT OVERVIEW (Q1–Q5)

---

### Q1. Tell me about your project. What problem does it solve?

**A:** SkillTube is a distraction-free YouTube learning app built with Flutter. The problem it solves is simple — YouTube is full of distractions. Ads, recommendations, comments, and shorts pull you away from focused learning. SkillTube lets you paste a YouTube URL, fetch video metadata automatically, save it to a personal library, and watch it in a clean player with no distractions. It also tracks your watch progress and resumes exactly where you left off.

---

### Q2. What was the most challenging feature to build?

**A:** The **custom fullscreen video player**. The `youtube_player_iframe` package doesn't natively support fullscreen well on all platforms. So I built a custom solution using Flutter's `OverlayPortal` — when the user taps fullscreen, the player widget is "beamed" to a top-level overlay that covers the entire screen. Then I rotate the device to landscape via `SystemChrome.setPreferredOrientations`. The tricky part was handling the **visual transition** — during rotation, the player stretches awkwardly. I solved this with a **fade-to-black animation** using `AnimationController` that covers the player during rotation and reveals it once the rotation completes. I also handled the back button via `PopScope` so pressing back exits fullscreen instead of navigating away.

---

### Q3. How does your app fetch video metadata without a YouTube API key?

**A:** I use the `youtube_explode_dart` package. It reverse-engineers YouTube's internal API to extract video metadata — title, thumbnail URL, channel name, and duration — directly from the video page. The advantage is **no API key required** and **no quota limits**. The downside is it can break if YouTube changes their internal structure, but the package is actively maintained and updated frequently.

---

### Q4. How do you handle the user's video library offline?

**A:** All video metadata is stored locally in **ObjectBox**, a high-performance NoSQL database. Once a video is added, its metadata (title, thumbnail URL, duration, channel, progress) is persisted locally. The app works fully offline for browsing the library. Video playback requires internet since the actual video streams from YouTube, but the library itself, progress tracking, and resume functionality all work offline.

---

### Q5. If you had more time, what features would you add?

**A:** Three things: (1) **Firebase Firestore sync** for multi-device support — I've already designed the Repository interface to support this, I'd add a Firestore data source and a SyncService. (2) **Playlists / Folders** — let users organize videos by topic. (3) **Smart search** with a local search query on ObjectBox to filter videos in the library.

---

## 🏗️ ARCHITECTURE (Q6–Q12)

---

### Q6. Explain the architecture of your app.

**A:** I follow **Clean Architecture** with 3 layers:

- **Presentation Layer**: Flutter widgets + BLoC for state management. Widgets dispatch events, BLoC processes them, emits new states, and widgets rebuild.
- **Domain Layer**: Pure Dart — no Flutter or package imports. Contains the `Video` entity (using `freezed`), the `VideoRepository` interface (abstract class), and 6 Use Case classes.
- **Data Layer**: Contains the `VideoModel` (ObjectBox entity), two data sources (`VideoLocalDataSource` for ObjectBox, `VideoRemoteDataSource` for YouTube), and `VideoRepositoryImpl` which coordinates them.

**Key principle**: Dependencies point inward. Domain knows nothing about ObjectBox, YouTube, or Flutter. This makes the domain layer testable and reusable.

---

### Q7. Why did you separate Entity from Model?

**A:** The `Video` entity is a **pure Dart class** using `freezed` — immutable, no database annotations, no serialization logic. It lives in the Domain layer and is what the Presentation layer works with.

The `VideoModel` is the **ObjectBox entity** with `@Entity()`, `@Id()`, `@Unique()` annotations. It lives in the Data layer.

The `VideoModel` has `toEntity()` and `fromEntity()` mapper methods. This separation means if I switch from ObjectBox to another database, I only change the Data layer — the Domain and Presentation layers are untouched.

---

### Q8. What is the `ResultFuture` type and why do you use it?

**A:** It's a type alias:
```dart
typedef ResultFuture<T> = Future<Either<Failure, T>>;
```
Every repository method returns this type. `Either` comes from `fpdart` — it's a functional programming construct that forces the caller to handle **both** the success case (`Right`) and the failure case (`Left`). Unlike `try-catch`, you can never accidentally forget to handle an error. The compiler enforces it.

---

### Q9. How does dependency injection work in your app?

**A:** I use **GetIt** as a service locator. In `injection_container.dart`, I register all dependencies during app startup:
- **External services** (ObjectBox Store, YoutubeExplode) as `registerLazySingleton` — created once, shared globally
- **Data sources** as `registerLazySingleton` — same instance reused
- **Repository** as `registerLazySingleton` — one instance shared across all use cases
- **Use Cases** as `registerLazySingleton` — stateless, safe to share
- **BLoC** as `registerFactory` — **new instance every time** because BLoC holds mutable state; using a singleton would share state across unrelated screens

The `sl()` shorthand auto-resolves dependencies by type.

---

### Q10. Why did you use `registerFactory` for BLoC but `registerLazySingleton` for everything else?

**A:** BLoC is **stateful** — it holds the current state and event history. If I used a singleton, multiple screens or widget rebuilds would share the same BLoC instance and see stale or conflicting state. `registerFactory` creates a fresh BLoC every time `sl<LibraryBloc>()` is called. Everything else (repositories, data sources, use cases) is **stateless or read-only**, so sharing a single instance is safe and more memory-efficient.

---

### Q11. How do you structure your use cases? Why not just call the repository directly from the BLoC?

**A:** Each use case is a single-purpose callable class:
```dart
class AddVideo extends FutureUseCaseWithParams<Video, String> {
  ResultFuture<Video> call(String params) => _repository.addVideo(params);
}
```
Reasons: (1) **Single Responsibility** — each use case does exactly one thing. (2) **Testability** — I can mock individual use cases when testing the BLoC. (3) **Business logic isolation** — if I need to add validation or preprocessing before a repository call, it goes in the use case, not the BLoC. (4) **Dependency clarity** — the BLoC constructor lists exactly which operations it needs.

---

### Q12. How is your routing set up?

**A:** I use `GoRouter` with declarative route configuration. Currently, the app has a single route (`/` → `DashboardPage`). I also attach a `TalkerRouteObserver` that automatically logs every navigation event (push, pop, replace) — this is useful for debugging and for the in-app log viewer.

---

## 🧠 STATE MANAGEMENT (Q13–Q18)

---

### Q13. Walk me through the BLoC events and states in your app.

**A:** I use **sealed classes** for both events and states:

**6 Events:**
1. `LibraryInitializedEvent` — dispatched on app launch
2. `LibraryVideoAddedEvent(url)` — user manually enters a URL
3. `LibraryVideoDeletedEvent(id)` — user confirms deletion
4. `LibraryVideoProgressUpdatedEvent(youtubeId, positionSeconds)` — heartbeat timer saves progress
5. `LibraryVideoAddedAndPlayRequested(url)` — clipboard "Watch Now"
6. `LibraryVideoSelectedEvent(video)` — user taps a video card

**5 States:**
1. `LibraryInitialState` — before first load (shows shimmer)
2. `LibraryLoadingState` — during add/delete (shows spinner)
3. `LibraryEmptyState` — no videos yet
4. `LibraryVideoLoadedState(libraryVideos, lastPlayVideo)` — main state
5. `LibraryFailureState(message)` — error occurred

---

### Q14. Why `sealed class` instead of `abstract class` for events and states?

**A:** `sealed class` gives **exhaustiveness checking** in Dart 3 switch expressions. When I write `switch (state)` in the UI, the compiler ensures I handle every possible state. If I add a new state later, I get compile-time errors everywhere I forgot to handle it. With `abstract class`, I'd use `if-else` chains with no compiler safety — I could silently miss a state.

---

### Q15. What is `_selectedHeroId` and why is it important?

**A:** It's the YouTube ID of the video the user explicitly tapped. Without it, every time the heartbeat saves progress (every 60 seconds), the BLoC calls `_refreshLibrary()`, which re-queries `getLastPlayedVideo()` from the database. Since saving progress updates `lastPlayedAt`, the "last played" video might change unexpectedly.

`_selectedHeroId` fixes this — once the user picks a video, `_refreshLibrary()` uses that ID instead of re-querying. This prevents the hero video from "jumping" during normal playback.

---

### Q16. How do you prevent unnecessary widget rebuilds?

**A:** Three strategies:
1. **`BlocBuilder.buildWhen`** — I provide a `buildWhen` callback that returns `true` only for specific state types (`Loaded`, `Initial`, `Empty`). The `LoadingState` and `FailureState` don't trigger rebuilds of the video player or list.
2. **`Equatable`** — All states extend `Equatable`, so if the BLoC emits a state that equals the current state, `flutter_bloc` automatically skips the emission.
3. **Separate `BlocListener` and `BlocBuilder`** — Error toasts use `BlocListener` (fires once, no rebuild), while the UI uses `BlocBuilder` (rebuilds on state change).

---

### Q17. How does the error flow work end-to-end?

**A:**
1. **DataSource** throws a typed exception: `throw VideoException('Video already exists', code: 'duplicate')`
2. **Repository** catches it in a `try-catch` and maps it: `return Left(VideoFailure(message: e.message, code: e.code))`
3. **BLoC** calls `result.fold()` — on `Left`, emits `LibraryFailureState(failure.message)`. Then calls `_refreshLibrary()` to recover the UI.
4. **Dashboard** has a `BlocListener` that catches `LibraryFailureState` and shows a toast with the error message.

The key insight is: exceptions **never** propagate to the UI. They're caught at the repository boundary and converted to failures.

---

### Q18. What happens if adding a video fails? Does the UI get stuck in a loading state?

**A:** No. In `_onVideoAdded`, after the failure is emitted, I immediately call `_refreshLibrary()` again. This re-fetches the existing video list and emits `LibraryVideoLoadedState`, which recovers the UI. The error toast appears briefly via `BlocListener`, and the video list is still visible underneath. Same pattern for delete failures.

---

## 📱 FEATURES (Q19–Q25)

---

### Q19. How does the clipboard detection feature work?

**A:** I built a `ClipboardMonitorMixin` that uses `WidgetsBindingObserver`:
1. When the app resumes from background (`AppLifecycleState.resumed`), it reads the clipboard
2. `ClipboardService` extracts a YouTube video ID using regex
3. It checks deduplication — `_lastProcessedUrl` ensures the same URL isn't processed twice, and `_promptedVideoIds` in the widget ensures we don't show repeated prompts in the same session
4. If it's a new URL, it shows a `ClipboardVideoPrompt` toast with "Add to Library" and "Watch Now" buttons
5. The toast auto-closes after 10 seconds and uses a slide-up animation

---

### Q20. How does the video progress tracking work?

**A:**
- A `Timer.periodic(60 seconds)` heartbeat reads `controller.currentTime` and dispatches `LibraryVideoProgressUpdatedEvent`
- Only saves if `position > 0` to avoid saving zero progress
- On video switch (`didUpdateWidget`), the **old** video's progress is saved immediately before loading the new one
- On `dispose()` (leaving page), final progress is saved
- Progress is stored as `lastWatchedPositionSeconds` in ObjectBox along with `lastPlayedAt = DateTime.now()`

---

### Q21. How does the resume logic work?

**A:** When initializing or switching videos:
```dart
final startPos = widget.video.isCompleted
    ? 0.0  // >95% watched → restart from beginning
    : widget.video.lastWatchedPositionSeconds.toDouble();  // resume
```
On first app launch, I use `cueVideoById()` (shows thumbnail, no auto-play). When the user taps a different video card, `didUpdateWidget` detects the new `youtubeId` and calls `loadVideoById()` (auto-plays).

---

### Q22. Why do you use `cueVideoById` vs `loadVideoById`?

**A:** `cueVideoById` loads the video metadata and shows the thumbnail/scrubber but **does not auto-play**. I use this on app launch so the player shows the last video without consuming bandwidth or being intrusive. `loadVideoById` loads **and** auto-plays — I use this when the user explicitly taps a video card, because that's a clear intent to watch.

---

### Q23. How does `getLastPlayedVideo` determine which video to show in the hero player?

**A:** Two-step query:
1. First: `WHERE lastPlayedAt != null ORDER BY lastPlayedAt DESC LIMIT 1` — the most recently watched video
2. Fallback: If no video has been played yet (fresh install), `ORDER BY addedAt DESC LIMIT 1` — the most recently added video

This ensures the hero player always shows something relevant.

---

### Q24. How do you handle duplicate video additions?

**A:** Two layers of protection:
1. In `VideoLocalDataSource.addVideo()`, I explicitly query `WHERE youtubeId == video.youtubeId` before inserting. If found, I throw `VideoException('Video already exists', code: 'duplicate')`.
2. ObjectBox's `@Unique()` annotation on `youtubeId` provides a database-level constraint. Even if my query check is bypassed somehow, ObjectBox will throw a unique constraint violation.

---

### Q25. How does the Add Video flow work end-to-end?

**A:**
1. User taps FAB → `AddVideoBottomSheet` opens with a `TextField`
2. User enters URL, taps "Add to Library" → calls `onAdd(url)` callback
3. Callback dispatches `LibraryVideoAddedEvent(url)` to `LibraryBloc`
4. BLoC emits `LibraryLoadingState`, calls `_addVideo(url)` use case
5. Use case calls `VideoRepositoryImpl.addVideo(url)`
6. Repo calls `VideoRemoteDataSource.fetchVideoDetails(url)` → `youtube_explode_dart` parses URL, fetches title/thumbnail/duration/channel
7. Repo calls `VideoLocalDataSource.addVideo(model)` → duplicate check → ObjectBox `put()`
8. Repo returns `Right(model.toEntity())`
9. BLoC calls `_refreshLibrary()` → fetches updated list → emits `LibraryVideoLoadedState`
10. `BlocBuilder` rebuilds the dashboard with the new video in the list

---

## 🔧 TECHNICAL DEEP-DIVES (Q26–Q30)

---

### Q26. How is your logging system designed?

**A:** I use the **Strategy Pattern**. There's an abstract `LoggingService` interface with methods like `log()`, `setUserIdentifier()`, `setCustomKey()`. The `AppLogger` class holds a `List<LoggingService>` and fans out every log call to all backends.

Currently, the only backend is `TalkerLoggingService` (console + in-app viewer). But I can add a `CrashlyticsLoggingService` or `AnalyticsLoggingService` without changing any calling code — just register a new service in the DI container. This follows the **Open/Closed Principle**.

I also have a `TalkerBlocObserver` that automatically logs every BLoC event, state change, and transition.

---

### Q27. How do you handle crashes in production?

**A:** Two hooks in `main.dart`:
- **Sync errors** (widget build failures, layout overflows): `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError`
- **Async errors** (unhandled Futures, isolate errors): `PlatformDispatcher.instance.onError = (error, stack) { FirebaseCrashlytics.instance.recordError(error, stack, fatal: true); return true; }`

This catches everything that Flutter and Dart can throw. Combined with structured logging via Talker, I can reproduce most issues from crash reports.

---

### Q28. Explain your design system. How do you manage consistent styling?

**A:** I built a **token-based design system**:
- `AppSizes` — standard spacing values (p4, p8, p12, p16, p24, p48)
- `AppRadius` — border radius presets (roundedS, roundedM, roundedL, roundedXL)
- `AppShadows` — elevation presets
- `AppDurations` — animation timing
- `AppColors` — semantic color palette

I also created a `ThemeExtension<AppColorsExtension>` for custom semantic colors (success, warning, textPrimary, textSecondary) with proper `lerp` for smooth theme transitions. The widgets use `context.colorScheme` and `context.textTheme` via context extensions for clean, readable code.

For buttons, I follow **Atomic Design** — a base `AppBaseButton` with 10+ variants (Primary, Secondary, Outline, Ghost, Social, Destructive, etc.).

---

### Q29. Why did you choose ObjectBox over Hive or SQLite?

**A:** Three reasons:
1. **Performance**: ObjectBox is roughly 10x faster than Hive for reads (according to their benchmarks). Since my app reads the entire video list on every refresh, speed matters.
2. **Typed Queries**: Unlike Hive (which is key-value), ObjectBox supports `WHERE`, `ORDER BY`, `LIMIT`, and `notNull()` filters. I need this for `getLastPlayedVideo()` — querying `WHERE lastPlayedAt != null ORDER BY lastPlayedAt DESC LIMIT 1`.
3. **No SQL boilerplate**: Unlike SQLite/Drift, I don't write SQL strings. Just Dart annotations (`@Entity()`, `@Unique()`, `@Property(type: PropertyType.dateNano)`) and the code generator handles the rest.

---

### Q30. If you were to rewrite this app today, what would you do differently?

**A:** A few things:
1. **Add unit tests from the start** — I should have had repository and BLoC tests using `mocktail` from day one
2. **Use Riverpod instead of BLoC** — for a single-feature app like this, Riverpod's lighter syntax might be more appropriate. BLoC shines in large teams and complex apps.
3. **Add a dedicated video player page** — right now the player is inline on the dashboard. A separate page with better controls (speed, skip, notes) would improve UX.
4. **Better error recovery in RemoteDataSource** — instead of defaulting unknown errors to `code: 'offline'`, I'd add proper network connectivity checks using `internet_connection_checker_plus` before making the YouTube API call.
