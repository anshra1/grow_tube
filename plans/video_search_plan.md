## Global and Local Video Search Implementation Plan

This plan details how we will implement the video search functionality in both the Playlists page and the Playlist Detail page.

## Goal Description
The objective is to allow users to search for videos by their title or channel name. 
1. **Global Search**: From the main `PlaylistsPage`, users can search across all videos in the app's library.
2. **Local Search**: From a specific `PlaylistDetailPage`, users can search exclusively for videos within that playlist.

## User Review Required
No major breaking changes. The search behavior will work as follows:
- Tapping a search result from **Global Search** will determine which playlist the video belongs to, navigate to that specific `PlaylistDetailPage`, and start playing the video.
- Tapping a search result from **Local Search** (already inside a playlist) will immediately play the video in the current playlist page.

## Proposed Changes

### Data Layer
#### [MODIFY] `lib/src/features/playlist/repositories/playlist_repository.dart`
- Add a custom result class `VideoSearchResult` containing the `PlaylistVideoModel`, its parent `playlistId`, and the playlist's title.
- Modify `searchVideos` to return a `List<VideoSearchResult>`. We will iterate through all playlists to find matching videos and attach their parent playlist ID so we know where to navigate.
- Keep `searchVideosInPlaylist` returning `List<PlaylistVideoModel>`.

### UI & Navigation
#### [NEW] `lib/src/features/playlist/views/video_search_delegate.dart`
Create a new class `VideoSearchDelegate`:
- **Constructor**: Accepts an optional `int? playlistId` and the `PlaylistRepository`.
- **Querying**: 
  - If `playlistId` is null (Global), calls `searchVideos(query)` and displays videos along with their parent playlist name.
  - If `playlistId` is provided (Local), calls `searchVideosInPlaylist(playlistId, query)`.
- **Action**: Tapping a result pops the `SearchDelegate` and returns the tapped video (and its playlist ID if global).

#### [MODIFY] `lib/src/features/playlist/views/playlists_page.dart`
- Add an `IconButton` (Search icon) to the `AppBar`'s `actions`.
- When tapped, invoke `showSearch` using `VideoSearchDelegate` (without a `playlistId`).
- Await the returned result. If not null, navigate to the specific playlist detail page and pass the video URL to automatically play it:
  ```dart
  context.push('/playlists/${result.playlistId}', extra: result.video.originalUrl ?? 'https://youtube.com/watch?v=${result.video.youtubeId}');
  ```

#### [MODIFY] `lib/src/features/playlist/views/playlist_detail_page.dart`
- Add an `IconButton` (Search icon) to the `AppBar`'s `actions`.
- When tapped, invoke `showSearch` using `VideoSearchDelegate` (passing the current `playlistId`).
- Await the returned `PlaylistVideoModel`. If not null, tell the `PlaylistDetailCubit` to select and play that video immediately:
  ```dart
  context.read<PlaylistDetailCubit>().selectVideo(video.toEntity());
  ```
