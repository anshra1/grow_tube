import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mx_youtube_player/src/widgets/mx_player_overlay.dart';
import 'package:mx_youtube_player/youtube_player_iframe.dart';

class MxPlayerScaffold extends StatefulWidget {
  final YoutubePlayerController controller;
  final String title;
  final String? channelName;
  final bool isHeroMode;
  final bool autoFullScreen;
  final Widget? child;

  const MxPlayerScaffold({
    super.key,
    required this.controller,
    required this.title,
    this.channelName,
    this.isHeroMode = false,
    this.autoFullScreen = true,
    this.child,
  });

  @override
  State<MxPlayerScaffold> createState() => _MxPlayerScaffoldState();
}

class _MxPlayerScaffoldState extends State<MxPlayerScaffold> {
  BoxFit _fit = BoxFit.contain;

  @override
  void initState() {
    super.initState();
    if (widget.autoFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _toggleZoom() {
    setState(() {
      _fit = _fit == BoxFit.contain ? BoxFit.cover : BoxFit.contain;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        final playerWidget = Stack(
          children: [
            Center(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: _fit,
                  child: SizedBox(
                    width: 16 * 100, // Aspect Ratio reference
                    height: 9 * 100,
                    child: YoutubePlayer(
                      controller: widget.controller,
                      aspectRatio: 16 / 9,
                    ),
                  ),
                ),
              ),
            ),
            MxPlayerOverlay(
              controller: widget.controller,
              title: widget.title,
              channelName: widget.channelName,
              isHeroMode: widget.isHeroMode,
              onToggleZoom: _toggleZoom,
            ),
          ],
        );

        return Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              // Player Section
              if (isLandscape)
                Expanded(child: playerWidget)
              else
                SizedBox(
                  height: MediaQuery.of(context).size.width * 9 / 16,
                  child: playerWidget,
                ),

              // Child Content (Only in Portrait)
              if (!isLandscape && widget.child != null) Expanded(child: widget.child!),
            ],
          ),
        );
      },
    );
  }
}
