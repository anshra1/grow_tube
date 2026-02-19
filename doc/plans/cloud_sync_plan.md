# Feature: Multi-Device Synchronization (Cloud Sync)

## Overview
Enable users to synchronize their video library and watch progress across multiple devices using Firebase Authentication and Cloud Firestore.

## 1. Prerequisites (Infrastructure)
1.  **Firebase Project Setup**: (User action required) Create a Firebase project and add Android/iOS apps.
2.  **Dependencies**:
    - `firebase_auth`: For identifying users.
    - `cloud_firestore`: For real-time database sync.
    - `google_sign_in`: For easy authentication.

## 2. Authentication Strategy (Guest First)
- **Default State**: **Guest Mode (Anonymous)**.
    - All features work immediately using local ObjectBox database.
    - No sign-in required to start using the app.
- **Upgrade Path**: **Google Sign-In**.
    - User chooses to "Sign In to Sync".
    - **Action**: Existing local data is **merged** with the new cloud account.
    - Result: Multi-device sync is enabled without data loss.
- **Library**: `firebase_auth` handles anonymous sessions and link-ups.

## 3. Data Architecture (Offline-First)

**Principle**: `ObjectBox` remains the **Single Source of Truth** for the UI. The app reads/writes to ObjectBox directly. Firestore acts as a background synchronization layer.

### 3.1 The Sync Engine
A new `SyncRepository` will mediate between ObjectBox and Firestore.

1.  **Local Writes (UI -> ObjectBox)**:
    - User adds video / watches video.
    - App writes to ObjectBox (fast, offline-ready).
    - **Side Effect**: `SyncRepository` detects this change and *pushes* it to Firestore (if online).

2.  **Remote Updates (Firestore -> ObjectBox)**:
    - The app listens to the Firestore `videos` collection stream.
    - When a document changes (from another device), `SyncRepository` updates the local ObjectBox entity.
    - **Loop Prevention**: We must ensure that an update from Firestore doesn't trigger a "local write" event that sends it back to Firestore.

### 3.2 Data Model Extensions
We need to track *when* data changed to resolve conflicts.
- **Local (ObjectBox)**: Add `updatedAt` (DateTime) to `Video` entity.
- **Remote (Firestore)**: Use `serverTimestamp` for modifications.
- **Conflict Resolution**: Last Write Wins (based on `updatedAt`).

## 4. Implementation Steps

### Phase 1: Infrastructure & Auth
1.  Add Firebase dependencies.
2.  Implement `AuthRepository` (Google Sign-In).
3.  Create the `users/{userId}/videos` collection structure.

### Phase 2: Sync Service Implementation
1.  Create `FirestoreDataSource`: Handles raw Firestore CRUD.
2.  Create `SyncRepository`:
    - Listens to ObjectBox stream (`box.query().watch()`).
    - Listens to Firestore stream (`collection.snapshots()`).
    - Implements the "Push/Pull" logic with loop protection.
    
### Phase 3: Integration
1.  Initialize `SyncRepository` on app startup (after Auth check).
2.  Bind `AuthRepository` events:
    - **On Login**: Trigger "Initial Sync" (Merge Cloud & Local).
    - **On Logout**: Stop syncing (keep local data? or clear? -> usually keep).

### Phase 4: Testing & Edge Cases
1.  **Offline Edits**: Change data while airplane mode -> turn on -> verify sync.
2.  **Race Conditions**: Edit same video on two devices simultaneously.


## 5. User Questions
- Do you have the Firebase project created?
- Do you prefer Google Sign-In?
