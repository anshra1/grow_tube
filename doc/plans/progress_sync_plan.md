# Feature: Intelligent Progress Synchronization

## Overview
Replicate the seamless "YouTube-style" watch progress syncing across devices while optimizing for database costs and network efficiency.

## 1. Core Principles
1.  **Event-Driven Sync (Instant)**: The most critical synchronization moments are user actions.
2.  **Heartbeat Sync (Safety)**: A periodic background save to prevent data loss during crashes/battery death.
3.  **Last Write Wins**: Concurrency resolution strategy where the latest timestamp is authoritative.
4.  **Optimistic UI**: Local state is always trusted immediately; cloud updates merge silently.

## 2. Synchronization Triggers

| Trigger | Description | Frequency | Implementation Status |
| :--- | :--- | :--- | :--- |
| **Pause** | User taps pause button. | **Instant** | ✅ Implemented in `DashboardVideoPlayer` |
| **Dispose** | Player widget is removed (e.g., navigating away, closing app). | **Instant** | ✅ Implemented in `DashboardVideoPlayer` |
| **Fullscreen**| Transitioning between inline/fullscreen modes. | **Instant** (Side-effect) | ✅ Implicitly handled by widget rebuild/dispose |
| **Heartbeat** | Periodic background save while playing. | **Every 60s** | ✅ Implemented (Timer) |
| **Seek** | User scrubs through the timeline. | **Deferred** | ❌ Not explicit (handled by next heartbeat/pause). Considered sufficient. |

## 3. Data Flow

### 3.1 Writing Progress (Local -> Cloud)
1.  **Event**: `DashboardVideoPlayer` detects a trigger (e.g., Pause).
2.  **Action**: Calls `LibraryBloc.add(LibraryVideoProgressUpdatedEvent)`.
3.  **Local Save**: `VideoLocalDataSource` updates ObjectBox immediately.
4.  **Cloud Push**: `SyncRepository` (to be implemented) detects the ObjectBox change and pushes to Firestore `users/{uid}/videos/{videoId}`.
    - **Optimization**: Debounce pushes if they happen too rapidly (e.g., repeated seeking).

### 3.2 Reading Progress (Cloud -> Local)
1.  **Listener**: `SyncRepository` listens to Firestore stream.
2.  **Update**: When a document changes:
    - Compare `updatedAt` timestamps.
    - If `remote.updatedAt > local.updatedAt`, update ObjectBox.
3.  **UI Refresh**: `LibraryBloc` re-emits state with new progress.

## 4. Edge Cases & Handling

### 4.1 Conflict Resolution (The "Airplane Mode" Problem)
*   **Scenario**: User watches Video A offline on Phone (progress: 10:00). Meanwhile, Tablet (online) is at 5:00. Phone comes online.
*   **Resolution**: Sync logic must compare `lastPlayedAt` or `updatedAt`. The later timestamp (10:00) wins.

### 4.2 Completion Reset
*   **Rule**: If progress > 95%, treat as "Completed".
*   **Action**: Next time the video is opened on *any* device, verify cached progress. If marked completed, reset to 0:00.

### 4.3 App Resume (Cold Start)
*   **Scenario**: User opens app after watching on another device.
*   **Action**:
    1.  App starts -> Loads local ObjectBox data (Fast).
    2.  `SyncRepository` initializes -> Fetches latest from Cloud.
    3.  If Cloud has newer progress -> Update ObjectBox -> UI refreshes silently.

## 5. Technical Implementation Plan
1.  **Modify `Video` Entity**: Ensure `updatedAt` field exists and is updated on every save.
2.  **Modify `DashboardVideoPlayer`**:
    - Ensure `_saveProgress` calculates `progressPercent`.
    - If `progressPercent > 0.95`, save as `0` (or mark completed flag).
3.  **Implement `SyncRepository`**: The bridge between ObjectBox events and Firestore.

## 6. Metric for Success
*   **User Test**: Watch video on Simulator A -> Pause at 1:00 -> Open Simulator B -> Video should show progress at 1:00 (or close to it).
