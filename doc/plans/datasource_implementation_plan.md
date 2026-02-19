# Plan: Robust Offline-First Progress Sync

## Core Philosophy
1.  **Local First**: The app must work perfectly without internet. Local DB is the immediate source of truth for UI.
2.  **Cloud Enhancement**: Sync is a background optimization, not a blocker.
3.  **Conflict Resolution**: "Last Write Wins" based on `updatedAt` timestamp.

## 1. Architecture Components

### A. Interfaces & Data Sources
1.  **`VideoLocalDataSource`** (Existing):
    -   Manages ObjectBox.
    -   **Update**: Method signature changes to `updateVideoProgress(id, position, {DateTime? updatedAt})`.
2.  **`VideoRemoteDataSource`** (New Interface):
    -   Abstracts the backend.
    -   Methods:
        -   `Future<void> pushProgress(String id, int position, DateTime updatedAt);`
        -   `Stream<List<VideoDto>> pullProgressStream();`
3.  **`FirestoreVideoDataSource`** (New Implementation):
    -   Implements `VideoRemoteDataSource`.
    -   Handles Firestore logic (paths, collections).

### B. Data Models
1.  **`VideoModel` (Local)**: Add `DateTime? updatedAt` property.
2.  **`VideoDto` (Remote)**: Create DTO with `id`, `position`, `updatedAt` (Firestore Timestamp).

## 2. VideoRepositoryImpl (The Orchestrator)

The repository coordinates the show.

### A. Writing Progress (`updateVideoProgress`)
**Flow:**
1.  **Capture Time**: `final now = DateTime.now();`
2.  **Local Write (Critical)**:
    -   `_localDataSource.updateVideoProgress(id, position, updatedAt: now);`
    -   This guarantees the UI is always responsive.
3.  **Sync Logic (Background)**:
    -   Check Auth: `if (!_authRepo.isSignedIn()) return;`
    -   Check Optimization Rules (Debounce):
        -   `isFirstWatch`: `oldPos == 0 && newPos > 30`
        -   `isResumed`: `abs(newPos - oldPos) > 5`
    -   **If Sync Needed**:
        ```dart
        try {
          // Fire and forget - do not await if we don't want to block, 
          // or await but catch errors so they don't bubble up.
          await _remoteDataSource.pushProgress(id, position, now); 
        } catch (e, st) {
          _talker.handle(e, st, "Sync Failed");
          // Do nothing else. Local data is already safe.
        }
        ```

### B. Reading Progress (The "Pull" Listener)
**Flow:**
1.  **Init**: In Repository constructor, subscribe to `_remoteDataSource.pullProgressStream()`.
2.  **On Data Received (List<VideoDto>)**:
    -   For each `remoteVideo`:
        -   Fetch `localVideo = _localDataSource.getVideo(remoteVideo.id)`.
        -   **Conflict Resolution**:
            -   `IF (localVideo == null)`: Insert remote video.
            -   `IF (remoteVideo.updatedAt > localVideo.updatedAt)`: Update local DB.
            -   `ELSE`: Ignore remote (Local version is newer).

## 3. Implementation Steps
1.  **Model Updates**: Add `updatedAt` field to `VideoModel` and run build_runner.
2.  **Interface Creation**: Create `VideoRemoteDataSource` and `FirestoreVideoDataSource`.
3.  **Repository Refactor**:
    -   Inject `VideoRemoteDataSource`.
    -   Implement the "Last Write Wins" logic in the listener.
    -   Implement the safe `try-catch` wrapper in the update method.
4.  **DI Setup**: Register the new data source in `injection_container.dart`.
