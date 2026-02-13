# Smart Clipboard Video Player Feature Plan (v2)

## 1. Overview
The goal of this feature is to create a seamless experience where users can copy a YouTube URL from an external source and, upon opening GrowTube, be prompted to automatically save and play that video. This plan outlines a robust, decoupled, and maintainable architecture.

### New User Flow:
1.  **Copy Link** (External)
2.  **Open GrowTube** -> **A Toast Notification appears** -> **Click "Play"** -> **Watch** 🍿

---

## 2. Architecture & Components

### 2.1. `ClipboardService` (Decoupled Logic)
This new service will encapsulate all clipboard-related functionality, ensuring it's reusable and testable in isolation.

*   **Location**: `lib/src/core/services/clipboard_service.dart`
*   **Responsibilities**:
    *   `Future<String?> getClipboardText()`: Reads text from the system clipboard.
    *   `String? extractYouTubeId(String url)`: Validates and extracts the video ID using regex.
    *   `bool isNewUrl(String url)`: Compares the given URL with an internally stored `_lastProcessedUrl` to prevent re-prompting for the same link.
    *   `void clearLastUrl()`: Resets the last processed URL.

### 2.2. `ClipboardMonitorMixin` (Reusable UI Logic)
A mixin to provide the clipboard monitoring functionality to any `StatefulWidget`.

*   **Location**: `lib/src/core/mixins/clipboard_monitor_mixin.dart`
*   **Mechanism**:
    *   Uses `WidgetsBindingObserver`.
    *   Depends on the `ClipboardService`.
    *   When `didChangeAppLifecycleState` detects `resumed`, it calls the `ClipboardService` to check for a new, valid YouTube URL.
    *   If a new URL is found, it calls an abstract method `onClipboardUrlDetected(String url)` which the host widget must implement.

### 2.3. `LibraryBloc` (Refined State Management)
The BLoC will be updated to handle the "add and play" flow more gracefully.

*   **New Event**: `LibraryVideoAddedAndPlayRequested(String url)`
*   **New State**: `LibraryPlayVideoSuccess(String videoId)` - A transient state specifically to trigger navigation.
*   **Logic**:
    1.  On `LibraryVideoAddedAndPlayRequested`, the BLoC adds the video.
    2.  If successful, it emits `LibraryPlayVideoSuccess(videoId)`.
    3.  The UI listener will catch this specific state to navigate.

---

## 3. Technical Implementation Plan

### Step 1: Create `ClipboardService`
*   **File**: `lib/src/core/services/clipboard_service.dart`
*   **Action**: Implement the class with the responsibilities outlined in **2.1**. Use `flutter/services.dart` for clipboard access and the provided regex for validation.

### Step 2: Create `ClipboardMonitorMixin`
*   **File**: `lib/src/core/mixins/clipboard_monitor_mixin.dart`
*   **Action**:
    *   Create a mixin on `State<StatefulWidget>` that also implements `WidgetsBindingObserver`.
    *   Add `initState` and `dispose` methods to register/unregister the observer.
    *   Implement `didChangeAppLifecycleState` to orchestrate the check.
    *   Define `void onClipboardUrlDetected(String url);`.

### Step 3: Update `LibraryBloc`
*   **Files**: `library_event.dart`, `library_state.dart`, `library_bloc.dart`
*   **Action**:
    *   Add the new `LibraryVideoAddedAndPlayRequested` event.
    *   Add the new `LibraryPlayVideoSuccess` state.
    *   In the `LibraryBloc`, create an event handler for `LibraryVideoAddedAndPlayRequested` that adds the video and then emits `LibraryPlayVideoSuccess`.

### Step 4: Integrate into `DashboardPage`
*   **File**: `lib/src/features/library/presentation/pages/dashboard/dashboard_page.dart`
*   **Action**:
    1.  Apply the `ClipboardMonitorMixin` to the `_DashboardPageState`.
    2.  Implement the `onClipboardUrlDetected(String url)` method. Inside this method, show a `Toastification` notification.
    3.  The `Toastification` will have a "Play" button. Its `onPressed` callback will dispatch the new `LibraryVideoAddedAndPlayRequested(url)` event to the `LibraryBloc`.
    4.  Update the `BlocConsumer`'s `listener` to also handle the new `LibraryPlayVideoSuccess` state. When this state is received, it will execute `context.push('/player/{videoId}')`.

### Step 5: Refine Edge Cases
*   **Duplicate Videos**: The `LibraryBloc`'s `addVideo` use case should be idempotent. If a video already exists, it should not create a duplicate but should still proceed to the "success" state for the "Play" request.
*   **Network Failure**: If the `LibraryVideoAddedAndPlayRequested` event fails, the BLoC should emit `LibraryFailureState`. The UI's `listener` will show an error toast, and the flow will stop.
*   **Dialog Spam**: The logic in `ClipboardService` to track the `_lastProcessedUrl` will prevent the toast from appearing repeatedly for the same copied link.

---

## 4. Next Steps
1.  Implement the `ClipboardService`.
2.  Implement the `ClipboardMonitorMixin`.
3.  Update the `LibraryBloc` with the new event and state.
4.  Apply the mixin to `DashboardPage` and implement the `Toastification` prompt and navigation listener.
