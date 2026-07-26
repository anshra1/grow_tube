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
  const AddVideoSuccess();
}

final class CreatePlaylistSuccess extends AddState {
  const CreatePlaylistSuccess();
}

final class ImportPlaylistSuccess extends AddState {
  const ImportPlaylistSuccess();
}

final class AddError extends AddState {
  const AddError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
