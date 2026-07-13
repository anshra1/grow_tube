import 'package:fpdart/fpdart.dart';
import 'package:levelup_tube/src/core/common/typedef.dart';
import 'package:levelup_tube/src/core/common/usecase.dart';
import 'package:levelup_tube/src/core/error/failure.dart';
import 'package:levelup_tube/src/features/library/domain/entities/video.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/core/utils/youtube_url_parser.dart';

// ══════════════════════════════════════════════════════════════════════════════
// GET ALL VIDEOS
// ══════════════════════════════════════════════════════════════════════════════

class GetAllVideos extends FutureUseCaseWithoutParams<List<Video>> {
  const GetAllVideos(this._repository);
  final PlaylistRepository _repository;

  @override
  ResultFuture<List<Video>> call() async {
    try {
      final library = await _repository.getDefaultLibrary();
      final videos = library.videos.map((v) => v.toEntity()).toList();
      videos.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return Right(videos);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }
}

class GetVideo extends FutureUseCaseWithParams<Video?, String> {
  const GetVideo(this._repository);
  final PlaylistRepository _repository;

  @override
  ResultFuture<Video?> call(String youtubeId) async {
    try {
      final library = await _repository.getDefaultLibrary();
      final video = library.videos
          .where((v) => v.youtubeId == youtubeId)
          .map((v) => v.toEntity())
          .firstOrNull;
      return Right(video);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GET LAST PLAYED VIDEO
// ══════════════════════════════════════════════════════════════════════════════

class GetLastPlayedVideo extends FutureUseCaseWithoutParams<Video?> {
  const GetLastPlayedVideo(this._repository);
  final PlaylistRepository _repository;

  @override
  ResultFuture<Video?> call() async {
    try {
      final library = await _repository.getDefaultLibrary();
      if (library.videos.isEmpty) return const Right(null);

      final videos = library.videos.toList();
      videos.sort((a, b) {
        if (a.lastPlayedAt != null && b.lastPlayedAt != null) {
          return b.lastPlayedAt!.compareTo(a.lastPlayedAt!);
        }
        if (a.lastPlayedAt != null) return -1;
        if (b.lastPlayedAt != null) return 1;
        return b.addedAt.compareTo(a.addedAt);
      });

      return Right(videos.first.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADD VIDEO
// ══════════════════════════════════════════════════════════════════════════════

class AddVideo extends FutureUseCaseWithParams<Video, String> {
  const AddVideo(this._repository);
  final PlaylistRepository _repository;

  @override
  ResultFuture<Video> call(String url) async {
    try {
      await _repository.addVideoToLibrary(url);
      final videoId = YoutubeUrlParser.extractVideoId(url);
      if (videoId == null) {
         return const Left(ServerFailure(message: 'Invalid YouTube URL', statusCode: 400));
      }
      final library = await _repository.getDefaultLibrary();
      final video = library.videos.firstWhere((v) => v.youtubeId == videoId);
      return Right(video.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DELETE VIDEO
// ══════════════════════════════════════════════════════════════════════════════

class DeleteVideo extends FutureUseCaseWithParams<void, int> {
  const DeleteVideo(this._repository);
  final PlaylistRepository _repository;

  @override
  ResultFuture<void> call(int id) async {
    try {
      await _repository.removeVideoFromLibrary(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// UPDATE VIDEO PROGRESS
// ══════════════════════════════════════════════════════════════════════════════

class UpdateVideoProgressParams {
  const UpdateVideoProgressParams({
    required this.youtubeId,
    required this.positionSeconds,
  });
  final String youtubeId;
  final int positionSeconds;
}

class UpdateVideoProgress extends FutureUseCaseWithParams<void, UpdateVideoProgressParams> {
  const UpdateVideoProgress(this._repository);
  final PlaylistRepository _repository;

  @override
  ResultFuture<void> call(UpdateVideoProgressParams params) async {
    try {
      await _repository.updateVideoProgress(params.youtubeId, params.positionSeconds);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }
}
