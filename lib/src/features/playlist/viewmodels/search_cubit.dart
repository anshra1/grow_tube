import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/models/video_search_result.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required PlaylistRepository repository, this.playlistId})
      : _repository = repository,
        super(const SearchInitial());

  final PlaylistRepository _repository;
  final int? playlistId;
  Timer? _debounceTimer;

  void search(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    // Emit loading immediately or after a small delay to avoid flicker
    emit(const SearchLoading());

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (isClosed) return;

      try {
        if (playlistId != null) {
          final videos = await _repository.searchVideosInPlaylist(playlistId!, query);
          final playlist = await _repository.getPlaylist(playlistId!);
          final playlistTitle = playlist?.title ?? 'Playlist';
          
          final results = videos.map((v) => VideoSearchResult(
            video: v,
            playlistId: playlistId!,
            playlistTitle: playlistTitle,
          )).toList();
          
          if (isClosed) return;
          emit(SearchLoaded(videos: results));
        } else {
          final playlistsFuture = _repository.searchPlaylists(query);
          final videosFuture = _repository.searchVideos(query);
          final results = await Future.wait([playlistsFuture, videosFuture]);

          if (isClosed) return;
          emit(SearchLoaded(
            playlists: results[0] as List<PlaylistModel>,
            videos: results[1] as List<VideoSearchResult>,
          ));
        }
      }on Exception catch (_) {
        if (isClosed) return;
        emit(const SearchError('Failed to search.'));
      }
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
