# Tech Stack

## 0. Purpose

This document defines the **complete, approved technology stack** for this project.

> **What technologies are allowed to be used to build and operate this system?**

Anything not listed here is **not allowed** unless explicitly approved.

> [!IMPORTANT]
> **AI Instructions:** Before adding ANY new package, library, or dependency, you MUST ask for explicit approval.

---

## 1. Product & Scope

| Attribute | Value |
|-----------|-------|
| Application Type | Mobile Application |
| Framework Output | Android (`.apk`, `.aab`), iOS (`.ipa`) |
| Target Platforms | Android, iOS |
| Project Scale | Enterprise / Production-ready |
| Performance Sensitivity | High |

---

## 2. Language & SDK

| Component | Requirement |
|-----------|-------------|
| Framework | Flutter (Stable channel only) |
| Null Safety | **Mandatory** |
| Flutter SDK | >=3.9.0 <4.0.0 |

---

## 3. Architecture Pattern

| Layer | Pattern | Implementation |
|-------|---------|----------------|
| Presentation | BLoC | `flutter_bloc` for state, widgets for UI |
| Domain | Clean Architecture | Use cases, entities, repository interfaces |
| Data | Repository Pattern | Concrete implementations, data sources |
| Error Handling | Functional | `Either<Failure, Success>` via `fpdart` |

> [!NOTE]
> Never throw exceptions for expected errors. Always return `Either<L, R>` types.

---

## 4. State Management

| Purpose | Package |
|---------|---------|
| Primary State | `flutter_bloc` |
| Value Equality | `equatable` |

> [!CAUTION]
> No other state management solutions allowed. Do not use Provider, Riverpod, GetX, or MobX.

---

## 5. Dependency Injection

| Package | Purpose |
|---------|---------|
| `get_it` | Service locator for singleton services |
| `flutter_getit` | Flutter-specific DI helpers |

---

## 6. Navigation

| Package | Purpose |
|---------|---------|
| `go_router` | Declarative routing, deep linking, redirects, nested navigation |

---

## 7. Networking & Connectivity

| Package | Purpose |
|---------|---------|
| `internet_connection_checker_plus` | Check internet connectivity state |
| `youtube_explode_dart` | Fetch video metadata (title, thumbnail, duration) without API key |

> [!NOTE]
> This is an offline-first app. Direct API calls are minimized or removed in favor of local data handling.

---

## 8. Data Serialization

| Package | Purpose |
|---------|---------|
| `freezed` + `freezed_annotation` | Immutable data classes, sealed unions |
| `json_serializable` + `json_annotation` | JSON encoding/decoding |

> [!NOTE]
> Never write manual `fromJson`/`toJson` methods. Always use code generation.

---

## 9. Functional Programming

| Package | Purpose |
|---------|---------|
| `fpdart` | `Either`, `Option`, and functional utilities |

---

## 10. Storage & Caching

| Data Type | Package | Use Case |
|-----------|---------|----------|
| Cached Data | `objectbox` | Offline-first data, large datasets |
| Simple Flags | `shared_preferences` | Theme preference, simple app-level flags |

> [!CAUTION]
> **NEVER** store sensitive data in `shared_preferences` or `objectbox`.

---

## 11. UI & Design System

| Purpose | Package/Approach |
|---------|------------------|
| Design Language | Material Design 3 |
| UI Framework | Flutter Material widgets |
| Asset Generation | `flutter_gen` |
| Toast Notifications | `toastification` |
| Loading States | `shimmer` |
| Spacing | `gap` |
| Player UI | `omni_video_player` |
| Icons/Assets | `flutter_svg` |

**Styling Rules:**
- Centralized theme only
- No inline colors or text styles in widgets

---

## 12. Logging & Monitoring

| Package | Purpose |
|---------|---------|
| `talker` | Core logging |
| `talker_flutter` | In-app log viewer |
| `talker_bloc_logger` | Bloc state logging |
| `firebase_core` | Firebase initialization |
| `firebase_crashlytics` | Crash reporting |

---

## 13. Utilities

| Package | Purpose |
|---------|---------|
| `uuid` | Unique ID generation |
| `intl` | Date/number formatting, localization |
| `path_provider` | File system paths |

---

## 14. Testing Stack

| Purpose | Package |
|---------|---------|
| Mocking | `mocktail` |
| Fake Data | `faker` |
| Bloc Testing | `bloc_test` |

**Requirements:** Unit tests mandatory, widget tests required for complex UI.

---

## 15. Code Quality

| Tool | Purpose |
|------|---------|
| `very_good_analysis` | Strict lint rules |
| `dart format` | Code formatting |
| `build_runner` | Code generation |

---

## 16. Build & Environments

| Purpose | Tool |
|---------|------|
| Environment Config | Manual configuration (Dev, Stg, Prod) |

> [!NOTE]
> Flavorizr removed in favor of manual setup or simple conditional logic.

---

## 17. AI Behavior Rules

1. **Package Approval:** Ask before adding any new dependency.
2. **Error Handling:** Always use `Either<Failure, Success>` pattern.
3. **Separation of Concerns:** Blocs = logic, Widgets = UI, Repositories = data.
4. **Immutability:** Use `freezed` for all data models.
5. **Type Safety:** Avoid `dynamic` and `Object?`.
6. **Testing:** Write unit tests for use cases and repositories.

---

## 18. Constraints

| ❌ Prohibited | ✅ Use Instead |
|---------------|----------------|
| `http`, `dio` package | Local Storage / `internet_connection_checker_plus` |
| Manual JSON parsing | `json_serializable` |
| `print()` statements | `talker.log()` |
| Throwing exceptions | `Either<Failure, T>` |
| Multiple state libs | `flutter_bloc` only |
| Inline colors/styles | Centralized theme |
