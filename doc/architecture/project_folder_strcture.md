# 🏗️ Project Structure & Architecture Guide (Source Code)

**Welcome!** 👋

This document explains how the **grow tube** source code (`lib/`) is organized. We follow **Clean Architecture** combined with **Feature-First** organization. This structure separates code by *what it does* (Features) and then by *technical responsibility* (Layers).

---

## 1. Root Source Code (`lib/`)

The `lib` folder is the heart of the application. It is organized into entry points and the main source directory.

### 🚦 Entry Points
Different ways to start the app for different environments:
*   **`main_development.dart`**: Entry point for development.
*   **`main_staging.dart`**: Entry point for staging/QA.
*   **`main_production.dart`**: Entry point for production.
*   **`app.dart`**: The root UI widget (`MaterialApp`).
*   **`bootstrap.dart`**: Initialization logic (runs before the app starts).

---

## 2. Source Code (`lib/`)

The `lib` folder is the heart of the application.

### 📂 Directory Tree
```text
lib/
├── app.dart
├── bootstrap.dart
├── main_development.dart
├── main_production.dart
├── main_staging.dart
└── src/
    ├── core/
    │   ├── common/
    │   │   ├── typedef.dart
    │   │   └── usecase.dart
    │   ├── config/
    │   │   └── app_config.dart
    │   ├── constants/
    │   │   ├── api_endpoints.dart
    │   │   └── app_strings.dart
    │   ├── di/
    │   │   └── injection_container.dart
    │   ├── error/
    │   │   ├── exception.dart
    │   │   └── failure.dart
    │   ├── network/
    │   │   └── dio_client.dart
    │   ├── routing/
    │   │   └── app_router.dart
    │   ├── services/
    │   │   └── media_service.dart
    │   ├── theme/
    │   │   ├── app_colors.dart
    │   │   ├── app_theme.dart
    │   │   └── ... (radius, spacing, text_theme)
    │   ├── utils/
    │   │   └── extensions/
    │   └── widgets/
    │       └── atoms/ (buttons, etc.)
    └── features/
        └── authentication/
            ├── data/
            ├── domain/
            └── presentation/
                ├── bloc/
                ├── screens/
                └── widgets/
```

### 🚦 Entry Points

### 🅰️ `lib/src/core/` (Shared Modules)
Contains code shared across the entire application.

*   **`common/`**: Base definitions used everywhere.
    *   `typedef.dart`: Defines types like `ResultFuture`.
    *   `usecase.dart`: Base classes for business logic use cases.
*   **`config/`**: App configuration (`app_config.dart`).
*   **`constants/`**: Static values.
    *   `api_endpoints.dart`: API URL definitions.
    *   `app_strings.dart`: App-wide text strings.
*   **`di/`**: Dependency Injection setup (`injection_container.dart`).
*   **`error/`**: Error handling classes (`exception.dart`, `failure.dart`).
*   **`network/`**: Networking clients and configuration.
*   **`routing/`**: Navigation logic.
*   **`services/`**: Third-party service integrations.
*   **`storage/`**: Local storage implementations.
*   **`theme/`**: App styling and theme data.
*   **`utils/`**: Helper functions and utilities.
*   **`widgets/`**: Reusable, generic UI components.

### 🅱️ `lib/src/features/` (Vertical Slices)
Features are independent modules. Currently, existing features include:

*   **`library/`**: Manages the video feed and user's collection.
*   **`player/`**: The video playback experience.

---

## 3. Feature Structure (Example: `library`)

Inside a feature folder (like `lib/src/features/authentication`), we stick to **Clean Architecture** layers:

### 1. `domain/` (The Business Logic)
The "Rules" of the application. Pure Dart, no UI.
*   **`entities/`**: Core business objects (Freezed, immutable, no JSON).
*   **`repositories/`**: Interfaces defining *what* data operations can be done.
*   **`usecases/`**: Specific business actions the user can perform.

### 2. `data/` (The Implementation)
How we fetch and store data.
*   **`datasources/`**: Code that directly talks to APIs or local storage.
*   **`dtos/`**: Data Transfer Objects (raw data shapes).
*   **`models/`**: Data classes (usually extending Entities) with JSON parsing.
*   **`repositories/`**: Implementations of the domain repositories.

### 3. `presentation/` (The UI)
What the user sees.
*   **`bloc/`**: State management (Logic).
    *   Currently contains: `auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`.
*   **`screens/`**: Full-page views.
    *   Currently contains: `login_screen.dart`.
*   **`widgets/`**: Smaller UI components specific to this feature.


-------------------------------------------------------

