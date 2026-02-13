import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mx_youtube_player/youtube_player_iframe.dart' hide PlayerState;
import 'package:skill_tube/src/core/di/injection_container.dart' as di;
import 'package:skill_tube/src/features/player/presentation/bloc/player_bloc.dart';
import 'package:skill_tube/src/features/player/presentation/bloc/player_event.dart';
import 'package:skill_tube/src/features/player/presentation/bloc/player_state.dart';

class PlayerPage extends StatefulWidget {
  final String videoId;

  const PlayerPage({super.key, required this.videoId});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  YoutubePlayerController? _controller;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<PlayerBloc>()..add(PlayerVideoLoadedEvent(widget.videoId)),
      child: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerLoadedState) {
            _controller = YoutubePlayerController(
              params: YoutubePlayerParams(
                showControls: false, // We use our custom HUD
                showFullscreenButton: true,
                mute: false,
                strictRelatedVideos: true,
                playsInline: true,
                origin: 'https://www.youtube-nocookie.com',
              ),
            );

            _controller!.loadVideoById(
              videoId: state.video.youtubeId,
              startSeconds: state.video.isCompleted
                  ? 0
                  : state.video.lastWatchedPositionSeconds.toDouble(),
            );

            setState(() {});
          }
        },
        builder: (context, state) {
          if (state is PlayerLoadingState || _controller == null) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator(color: Colors.orange)),
            );
          }

          if (state is PlayerFailureState) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          }

          if (state is PlayerLoadedState && _controller != null) {
            return MxLandscapePlayer(
              controller: _controller!,
              title: state.video.title,
              channelName: state.video.channelName,
            );
          }

          return const Scaffold(backgroundColor: Colors.black, body: SizedBox.shrink());
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }
}
