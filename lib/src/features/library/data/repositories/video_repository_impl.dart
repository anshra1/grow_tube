import 'package:fpdart/fpdart.dart';
import 'package:skill_tube/main.dart';
import 'package:skill_tube/src/core/common/typedef.dart';
import 'package:skill_tube/src/core/error/exception.dart';
import 'package:skill_tube/src/core/error/failure.dart';
import 'package:skill_tube/src/features/library/data/datasources/video_local_datasource.dart';
import 'package:skill_tube/src/features/library/data/datasources/video_remote_datasource.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/domain/repositories/video_repository.dart';
import 'package:talker_flutter/talker_flutter.dart';

class VideoRepositoryImpl implements VideoRepository {
  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final VideoRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;

  @override
  ResultFuture<List<Video>> getAllVideos() async {
    try {
      final models = await localDataSource.getAllVideos();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on DatabaseException catch (e) {
      talker.error('Repository: Database error in getAllVideos: ${e.message}');
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      talker.error('Repository: Unknown error in getAllVideos: $e');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Video?> getLastPlayedVideo() async {
    try {
      final model = await localDataSource.getLastPlayedVideo();
      return Right(model?.toEntity());
    } on DatabaseException catch (e) {
      talker.error('Repository: Database error in getLastPlayedVideo: ${e.message}');
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      talker.error('Repository: Unknown error in getLastPlayedVideo: $e');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Video> addVideo(String url) async {
    talker.log('Repository: Adding video from URL: $url', logLevel: LogLevel.info);
    try {
      // 1. Fetch from Remote
      final model = await remoteDataSource.fetchVideoDetails(url);
      talker.log('Repository: Remote metadata fetched for ${model.title}', logLevel: LogLevel.debug);

      // 2. Save to Local
      await localDataSource.addVideo(model);
      talker.log('Repository: Video saved to local storage', logLevel: LogLevel.info);

      return Right(model.toEntity());
    } on VideoException catch (e) {
      talker.error('Repository: Video error adding video: ${e.message} (${e.code})');
      return Left(VideoFailure(message: e.message, code: e.code));
    } on DatabaseException catch (e) {
      talker.error('Repository: Database error adding video: ${e.message}');
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      talker.error('Repository: Unexpected error adding video: $e');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteVideo(int id) async {
    try {
      await localDataSource.deleteVideo(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      talker.error('Repository: Database error deleting video: ${e.message}');
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      talker.error('Repository: Unknown error deleting video: $e');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Video?> getVideo(String youtubeId) async {
    try {
      final model = await localDataSource.getVideo(youtubeId);
      return Right(model?.toEntity());
    } on DatabaseException catch (e) {
      talker.error('Repository: Database error getting video: ${e.message}');
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      talker.error('Repository: Unknown error getting video: $e');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> updateVideoProgress(String youtubeId, int positionSeconds) async {
    try {
      await localDataSource.updateVideoProgress(youtubeId, positionSeconds);
      return const Right(null);
    } on DatabaseException catch (e) {
      talker.error('Repository: Database error updating progress: ${e.message}');
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      talker.error('Repository: Unknown error updating progress: $e');
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
