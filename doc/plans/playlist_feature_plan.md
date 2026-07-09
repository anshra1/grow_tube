# Add Playlist Feature

## Goal
Add a comprehensive "Playlist" feature to LevelUp Tube. This allows users to:
1. View a list of their local playlists on a dedicated page.
2. Manually organize their saved videos into these playlists.
3. Import YouTube Playlists by pasting a playlist URL, which automatically fetches the videos and creates a local playlist.

## Detailed UI Flow & Design
1. **Dashboard (Homescreen):** 
   - A new, slightly smaller Floating Action Button (FAB) will be placed directly above the existing "Add Video" FAB.
   - Tapping it navigates to the new **Playlists Page**.

2. **Playlists Page:**
   - Displays all saved playlists.
   - Has its own primary FAB at the bottom right.
   - Tapping this FAB opens a bottom sheet strictly for **adding a playlist** (creating a custom one or importing via YouTube URL).

3. **Playlist Detail Page (Mirrors Homescreen):**
   - Tapping on a playlist opens a page that looks *exactly like the homescreen*.
   - It will feature a Hero Video Player at the top and a list of videos below it.
   - The only difference is that it will *only* show the videos contained within that specific playlist, giving the same seamless playback experience.

---

## 🛑 STRICT RULE: Reuse Over Rewrite
**Before creating any new code or UI in the `playlist` folder, we MUST check if it already exists in the `library` folder. We will reuse the following existing components:**

### UI Widgets (`lib/src/features/library/presentation/pages/widgets/`)
- **`dashboard_video_player.dart`**: Reuse as the Hero Player in `PlaylistDetailPage`.
- **`dashboard_video_list.dart`** & **`dashboard_video_card.dart`**: Reuse to display the list of videos inside the `PlaylistDetailPage`.
- **`dashboard_video_list_shimmer.dart`**: Reuse for loading states in `PlaylistDetailPage`.
- **`clipboard_video_prompt.dart`**: Extend this to detect playlist URLs (`&list=`).

### Network & Data (`lib/src/features/library/data/`)
- **`YoutubeApiService`**: Reuse for API calls. (Add a `fetchPlaylistItems` method).
- **`VideoRemoteDataSource`**: Reuse to fetch metadata for the videos inside a playlist.
- **`VideoModel` & `Video`**: Reuse as the core data type stored inside the new `PlaylistModel`.

---

## Proposed Technical Changes: MVVM Architecture

We will create a new top-level feature folder called `playlist` structured around Model-View-ViewModel (MVVM) instead of Clean Architecture.

**New Folder Path:** `lib/src/features/playlist/`

### 1. Models (`lib/src/features/playlist/models/`)
- **`playlist_model.dart`**: The ObjectBox entity. It will contain `id`, `title`, `createdAt`, and a `ToMany<VideoModel>` relation linking it to the existing `VideoModel`.
- **`playlist_repository.dart`**: Handles the ObjectBox database operations (`save`, `delete`, `getAll`). Uses the existing `YoutubeApiService` and `VideoRemoteDataSource` for fetching imported playlists.

### 2. ViewModels (`lib/src/features/playlist/viewmodels/`)
- **`playlist_viewmodel.dart`**: A `Cubit` (or standard `Bloc`) to act as our ViewModel. 
  - It will hold the state of the UI (e.g., loading, loaded playlists, error).
  - It will communicate with the `PlaylistRepository` and injected `YoutubeApiService`.
- **`playlist_detail_viewmodel.dart`** (optional): For managing the player state inside the Playlist Detail Page, reusing logic from the homescreen where possible.

### 3. Views (`lib/src/features/playlist/views/`)
- **`playlists_page.dart`**: The main screen showing all playlists.
- **`playlist_detail_page.dart`**: The screen showing videos inside a specific playlist (mimicking the `DashboardPage` layout by reusing its widgets).
- **`widgets/add_playlist_bottom_sheet.dart`**: The bottom sheet for creating/importing playlists.

### Changes to Existing Files
- **`lib/src/features/library/presentation/pages/dashboard_page.dart`**: Add the secondary FAB to navigate to the new `PlaylistsPage`.
- **`lib/src/features/library/data/models/video_model.dart`**: We may need to run ObjectBox generator commands to recognize the new relational links from `PlaylistModel`.
- **`lib/src/features/library/data/datasources/youtube_api_service.dart`**: Add a `fetchPlaylistItems` method to call the `playlistItems.list` API endpoint.
