import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

abstract class PlaylistRepository {
  Future<List<PlaylistModel>> getAllPlaylists();
  Future<PlaylistModel?> getPlaylist(int id);
  Future<int> createCustomPlaylist(String title);
  Future<int> importYoutubePlaylist(String playlistUrl);
  Future<bool> isPlaylistImported(String youtubePlaylistId);
  Future<void> deletePlaylist(int id);
  Future<void> removeVideoFromPlaylist(int playlistId, int videoModelId);
  Future<void> addVideoToPlaylist(int playlistId, String videoUrl);
  Future<void> updateVideoProgress(String youtubeId, int positionSeconds);
  
  /// Ensures the "My Library" system default playlist exists and returns it.
  Future<PlaylistModel> getOrCreateDefaultLibrary();

  /// Adds a video to the system default library playlist.
  Future<void> addVideoToLibrary(String videoUrl);

  /// Removes a video from the system default library playlist.
  Future<void> removeVideoFromLibrary(int videoModelId);

  /// Returns the default library playlist containing all standalone videos.
  Future<PlaylistModel> getDefaultLibrary();

  /// Atomically clears the default flag from all playlists and sets it
  /// on the playlist with [playlistId]. Throws if [playlistId] is not found.
  Future<void> setDefaultPlaylist(int playlistId);
}
