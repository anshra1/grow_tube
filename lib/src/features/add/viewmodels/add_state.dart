import 'package:equatable/equatable.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

sealed class AddState extends Equatable {
  const AddState();

  @override
  List<Object?> get props => [];
}

final class AddInitial extends AddState {
  const AddInitial({required this.playlists, this.defaultPlaylistId});
  final List<PlaylistModel> playlists;
  final int? defaultPlaylistId;

  @override
  List<Object?> get props => [playlists, defaultPlaylistId];
}

final class AddLoading extends AddState {
  const AddLoading();
}

final class AddVideoSuccess extends AddState {
  const AddVideoSuccess(this.playlistId, this.videoUrl);
  final int playlistId;
  final String videoUrl;

  @override
  List<Object?> get props => [playlistId, videoUrl];
}

final class CreatePlaylistSuccess extends AddState {
  const CreatePlaylistSuccess();
}

final class ImportPlaylistSuccess extends AddState {
  const ImportPlaylistSuccess(this.playlistId);
  final int playlistId;

  @override
  List<Object?> get props => [playlistId];
}

final class AddError extends AddState {
  const AddError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
