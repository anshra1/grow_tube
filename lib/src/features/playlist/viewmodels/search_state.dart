import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/models/video_search_result.dart';

abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  const SearchLoaded({
    this.playlists = const [],
    this.videos = const [],
  });

  final List<PlaylistModel> playlists;
  final List<VideoSearchResult> videos;
}

class SearchError extends SearchState {
  const SearchError(this.message);

  final String message;
}
