import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mx_youtube_player/youtube_player_iframe.dart';
import 'package:talker_flutter/talker_flutter.dart';

late final Talker talker;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  talker = TalkerFlutter.init();

  runApp(const SkillTubeApp());
}

class SkillTubeApp extends StatelessWidget {
  const SkillTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Tube - YouTube Player Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      navigatorObservers: [TalkerRouteObserver(talker)],
      home: const YoutubePlayerTestPage(),
    );
  }
}

class YoutubePlayerTestPage extends StatefulWidget {
  const YoutubePlayerTestPage({super.key});

  @override
  State<YoutubePlayerTestPage> createState() => _YoutubePlayerTestPageState();
}

class _YoutubePlayerTestPageState extends State<YoutubePlayerTestPage> {
  late final YoutubePlayerController _controller;

  // Sample video ID – Flutter vs React Native
  static const _videoId = 'tcodrIK2P_I';

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true, // MxPlayerScaffold handles controls
        showFullscreenButton: true, // MxPlayerScaffold handles fullscreen
        mute: false,
        strictRelatedVideos: true,
        playsInline: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );

    // Log all player state changes and errors
    _controller.listen((value) {
      talker.info('PlayerState: ${value.playerState}');
      talker.info('PlaybackQuality: ${value.playbackQuality}');
      talker.info('PlaybackRate: ${value.playbackRate}');
      talker.info(
        'MetaData: title=${value.metaData.title}, '
        'author=${value.metaData.author}, '
        'videoId=${value.metaData.videoId}, '
        'duration=${value.metaData.duration}',
      );

      if (value.error != YoutubeError.none) {
        talker.error('YouTube Error: ${value.error}');
      }
    }, cancelOnError: false);

    // Handle fullscreen: landscape + immersive + resume playback
    _controller.setFullScreenListener((isFullScreen) {
      talker.info('Fullscreen: $isFullScreen');

      if (isFullScreen) {
        // Enter landscape + hide system UI
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        // Restore portrait + show system UI
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }

      // Resume playback after transition settles
      Future.delayed(const Duration(milliseconds: 600), () {
        _controller.playVideo();
      });
    });

    talker.info('Controller initialized with videoId: $_videoId');
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MxPlayerScaffold(
      controller: _controller,
      autoFullScreen: false,
      title: 'YouTube Player Test',
      child: Scaffold(
        appBar: AppBar(title: const Text('YouTube Player Test'), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // — Video Metadata —
            //  _buildMetadataSection(),
            const SizedBox(height: 20),

            // — Speed Selector —
            //   _buildSpeedSelector(),
            const SizedBox(height: 20),

            // — Load Another Video —
            //  _buildVideoIdInput(),
            const SizedBox(height: 20),

            // — Talker Screen —
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TalkerScreen(talker: talker)),
                );
              },
              icon: const Icon(Icons.monitor_heart),
              label: const Text('Open Logs'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Metadata Section ───────────────────────────────────────

  Widget _buildMetadataSection() {
    return YoutubeValueBuilder(
      controller: _controller,
      builder: (context, value) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video Metadata',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _metadataRow('State', value.playerState.name),
                _metadataRow('Quality', value.playbackQuality ?? 'N/A'),
                _metadataRow('Playback Rate', '${value.playbackRate}×'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _metadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── Speed Selector ─────────────────────────────────────────

  Widget _buildSpeedSelector() {
    const speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

    return YoutubeValueBuilder(
      controller: _controller,
      builder: (context, value) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Playback Speed',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: speeds.map((speed) {
                    final isSelected = value.playbackRate == speed;
                    return ChoiceChip(
                      label: Text('$speed×'),
                      selected: isSelected,
                      onSelected: value.playerState != PlayerState.unknown
                          ? (_) => _controller.setPlaybackRate(speed)
                          : null,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Load Another Video ─────────────────────────────────────

  Widget _buildVideoIdInput() {
    final textController = TextEditingController();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Load Another Video',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Paste YouTube URL or Video ID',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Load'),
                  onPressed: () {
                    final input = textController.text.trim();
                    if (input.isNotEmpty) {
                      final id = _extractVideoId(input);
                      talker.info('Loading video: input="$input" → id="$id"');
                      _controller.loadVideoById(videoId: id);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Extracts a YouTube video ID from a URL or returns the input as-is.
  /// Supports:
  ///   - https://youtu.be/VIDEO_ID
  ///   - https://www.youtube.com/watch?v=VIDEO_ID
  ///   - https://youtube.com/watch?v=VIDEO_ID&t=123
  ///   - VIDEO_ID (raw)
  String _extractVideoId(String input) {
    // youtu.be short URL
    final shortMatch = RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})').firstMatch(input);
    if (shortMatch != null) return shortMatch.group(1)!;

    // youtube.com/watch?v=
    final longMatch = RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(input);
    if (longMatch != null) return longMatch.group(1)!;

    // youtube.com/embed/
    final embedMatch = RegExp(
      r'youtube\.com/embed/([a-zA-Z0-9_-]{11})',
    ).firstMatch(input);
    if (embedMatch != null) return embedMatch.group(1)!;

    // Assume raw video ID
    return input;
  }
}
