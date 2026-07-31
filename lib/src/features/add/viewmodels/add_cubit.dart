import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/error/exception.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_state.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';

class AddCubit extends Cubit<AddState> {
  AddCubit(this._repository) : super(const AddInitial(playlists: []));

  final PlaylistRepository _repository;

  /// Loads the playlists for the "Add Video" dropdown selector.
  Future<void> loadPlaylists() async {
    try {
      final playlists = await _repository.getAllPlaylists();
      final defaultPlaylist = await _repository.getOrCreateDefaultLibrary();

      // Filter out pinned playlists to put them at the top, if desired,
      // or just list them all. The dropdown usually just needs a list.
      emit(AddInitial(playlists: playlists, defaultPlaylistId: defaultPlaylist.id));
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'AddCubit: loadPlaylists error');
      emit(AddError(_exceptionMessage(e)));
    }
  }

  /// Adds a video to a specific playlist by its ID.
  Future<void> addVideoToPlaylist(int playlistId, String url) async {
    emit(const AddLoading());
    try {
      await _repository.addVideoToPlaylist(playlistId, url);
      emit(AddVideoSuccess(playlistId, url));
      // Reload playlists to reset the UI state
      await loadPlaylists();
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'AddCubit: addVideoToPlaylist error');
      emit(AddError(_exceptionMessage(e)));
      await loadPlaylists();
    }
  }

  /// Creates a new custom playlist with an optional cover image.
  Future<void> createPlaylist(String title, {String? localThumbnailPath}) async {
    if (title.trim().isEmpty) {
      emit(const AddError('Playlist name cannot be empty.'));
      await loadPlaylists();
      return;
    }

    emit(const AddLoading());
    try {
      final id = await _repository.createCustomPlaylist(title);

      // If a thumbnail was provided, update the playlist details.
      if (localThumbnailPath != null) {
        await _repository.updatePlaylistDetails(
          id,
          localThumbnailPath: localThumbnailPath,
        );
      }

      emit(const CreatePlaylistSuccess());
      await loadPlaylists();
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'AddCubit: createPlaylist error');
      emit(AddError(_exceptionMessage(e)));
      await loadPlaylists();
    }
  }

  /// Imports a YouTube playlist by URL.
  Future<void> importPlaylist(String url) async {
    if (url.trim().isEmpty) {
      emit(const AddError('YouTube URL cannot be empty.'));
      await loadPlaylists();
      return;
    }

    emit(const AddLoading());
    try {
      final newId = await _repository.importYoutubePlaylist(
        url,
        onProgress: (current, total, title, thumbnail) {
          emit(
            ImportPlaylistProgress(
              currentProgress: current,
              totalVideos: total,
              title: title,
              thumbnailUrl: thumbnail,
            ),
          );
        },
      );
      emit(ImportPlaylistSuccess(newId));
      await loadPlaylists();
    } on Exception catch (e, st) {
      di.sl<AppLogger>().handle(e, st, 'AddCubit: importPlaylist error');
      // Temporarily exposing raw exception string to help user debug
      emit(AddError(e.toString()));
      await loadPlaylists();
    }
  }

  String _exceptionMessage(Object exception) {
    // If it's our own AppException, use its message
    if (exception is AppException && exception.message.isNotEmpty) {
      return exception.message;
    }
    // For debugging, we return the full string representation
    return exception.toString();
  }
}
