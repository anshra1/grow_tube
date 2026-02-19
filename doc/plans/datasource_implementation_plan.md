# Plan: Implementing Progress Sync in Data Sources

## Overview
This plan details the changes required in the Data Layer (`DataSources` and `Repositories`) to implement the "Intelligent Progress Sync" logic (30-second rule, offline-first).

## 1. VideoRepositoryImpl (The Brain)
The repository mediates between Local and Remote data sources.

### core Logic: `updateVideoProgress`
Modify `updateVideoProgress(youtubeId, positionSeconds)`:

1.  **Read Local State**:
    - Call `localDataSource.getVideo(youtubeId)`.
    - Store `oldPosition = video.lastWatchedPositionSeconds`.
    - Store `updatedAt = video.updatedAt` (if exists).

2.  **Write Local State (Always)**:
    - Call `localDataSource.updateVideoProgress(youtubeId, positionSeconds)`.
    - This ensures the UI is instantly updated and works offline.
    
3.  **Evaluate for Cloud Sync**:
    - **Logic**:
        - `durationDelta = abs(positionSeconds - oldPosition)`
        - `isFirstWatch = oldPosition == 0 && positionSeconds > 30`
        - `isResumedWatch = oldPosition > 0 && durationDelta > 5`
    - **Decision**:
        - IF (`isFirstWatch` OR `isResumedWatch`): Call `_syncService.pushProgress(youtubeId, positionSeconds)`.
        - ELSE: Do nothing (Local-only update).

## 2. LocalDataSource (Optimization)
*   **Current State**: Good. Handles ObjectBox writes.
*   **Change**: Ensure `getVideo(id)` returns the *latest* state quickly.
*   **Add**: `updatedAt` field management. When updating progress, set `updatedAt = DateTime.now()`.

## 3. RemoteDataSource (Sync Service) 
Create a new `VideoRemoteDataSource` (or `SyncService`) exclusively for Firestore.

### Methods Needed:
1.  `pushProgress(String youtubeId, int positionSeconds, DateTime updatedAt)`:
    - Writes to `users/{uid}/videos/{youtubeId}`.
    - Uses `SetOptions(merge: true)` to avoid overwriting other fields (like title/thumbnail).
2.  `pullProgressStream()`:
    - Returns a `Stream<List<VideoDto>>` from Firestore.
    - Used by the repository to listen for updates from *other* devices.

## 4. VideoModel (Data Transfer Object)
*   **Current State**: ObjectBox entity.
*   **Change**: Add `DateTime? updatedAt` field.
    - Essential for conflict resolution (Last Write Wins).
    - Annotate with `@Property(type: PropertyType.date)` for ObjectBox.

## 5. Dependency Injection
1.  Register `VideoRemoteDataSource`.
2.  Update `VideoRepositoryImpl` to accept `VideoRemoteDataSource` as a dependency.

## 6. Implementation Order
1.  **Model**: Add `updatedAt` to `VideoModel`.
2.  **LocalSource**: Update `updateVideoProgress` to set `updatedAt`.
3.  **RemoteSource**: Create the Firestore implementation.
4.  **Repository**: Implement the "Brain" logic (Read -> Write Local -> Evaluate -> Write Remote).
