import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_tube/src/core/constants/app_icons.dart';
import 'package:skill_tube/src/core/constants/app_strings.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/mixins/clipboard_monitor_mixin.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:skill_tube/src/core/widgets/app_scaffold.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_state.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/add_video_bottom_sheet.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/clipboard_video_prompt.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_header.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_video_list.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_video_player.dart';
import 'package:toastification/toastification.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with ClipboardMonitorMixin {
  /// Keeps track of video IDs we've already shown a prompt for in this session.
  final Set<String> _promptedVideoIds = {};

  @override
  void onClipboardUrlDetected(String url, String videoId) {
    if (_promptedVideoIds.contains(videoId)) return;

    _promptedVideoIds.add(videoId);
    toastification.showCustom(
      context: context,
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 10),
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation),
          child: child,
        );
      },
      builder: (context, holder) {
        return ClipboardVideoPrompt(
          url: url,
          onDismiss: () => toastification.dismiss(holder),
          onAdd: () {
            context.read<LibraryBloc>().add(LibraryVideoAddedEvent(url));
            toastification.dismiss(holder);
          },
          onWatch: () {
            context.read<LibraryBloc>().add(LibraryVideoAddedAndPlayRequested(url));
            toastification.dismiss(holder);
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  bool _isFullScreen = false;
  final GlobalKey _playerKey = GlobalKey();

  void _onFullScreenChanged(bool isFull) {
    setState(() => _isFullScreen = isFull);
  }

  void _exitFullScreen() async {
    setState(() => _isFullScreen = false);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: PopScope(
        canPop: !_isFullScreen,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_isFullScreen) _exitFullScreen();
        },
        child: BlocConsumer<LibraryBloc, LibraryState>(
          buildWhen: (previous, current) =>
              current is! LibraryPlayVideoSuccess &&
              (current is LibraryLoadedState ||
                  current is LibraryEmptyState ||
                  (current is LibraryLoadingState && previous is LibraryInitialState)),
          listener: (context, state) async {
            switch (state) {
              case LibraryFailureState(:final message):
                toastification.show(
                  context: context,
                  type: ToastificationType.error,
                  style: ToastificationStyle.fillColored,
                  title: Text(AppStrings.dashboardError),
                  description: Text(message),
                  autoCloseDuration: const Duration(seconds: 4),
                  alignment: Alignment.bottomCenter,
                );
              case LibraryPlayVideoSuccess():
                break;
              default:
                break;
            }
          },
          builder: (context, state) {
            return switch (state) {
              LibraryInitialState() || LibraryLoadingState() => Center(
                child: CircularProgressIndicator(color: context.colorScheme.primary),
              ),
              LibraryFailureState(:final message) => Center(
                child: Text(message, style: TextStyle(color: context.colorScheme.error)),
              ),
              LibraryEmptyState() => Center(
                child: Text(
                  AppStrings.dashboardNoVideos,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              LibraryLoadedState(:final videos, :final heroVideo) => _buildLoadedContent(
                videos,
                heroVideo,
              ),
              LibraryPlayVideoSuccess() => const SizedBox.shrink(),
            };
          },
        ),
      ),
      floatingActionButton: !_isFullScreen
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => AddVideoBottomSheet(
                    onAdd: (url) {
                      context.read<LibraryBloc>().add(LibraryVideoAddedEvent(url));
                    },
                  ),
                );
              },
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
              child: const Icon(AppIcons.add),
            )
          : null,
    );
  }

  Widget _buildLoadedContent(List<Video> videos, Video? heroVideo) {
    // Build the player widget once — it will be placed in different
    // layout positions depending on fullscreen state, but always
    // with the same GlobalKey so Flutter keeps it mounted.
    final player = heroVideo != null
        ? DashboardVideoPlayer(
            key: _playerKey,
            video: heroVideo,
            isFullScreen: _isFullScreen,
            onFullScreenChanged: _onFullScreenChanged,
          )
        : null;

    // ── Fullscreen mode: black background, player fills screen ──
    if (_isFullScreen && player != null) {
      return ClipRect(
        child: Container(color: Colors.black, child: player),
      );
    }

    // ── Normal mode: header + player + video list ──
    return SafeArea(
      child: Column(
        children: [
          const DashboardHeader(),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (player != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                      child: Column(children: [gapH16, player, gapH16]),
                    ),
                  ),
                DashboardVideoList(videos: videos),
                const SliverToBoxAdapter(child: gapH48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didChangeViewFocus(ViewFocusEvent event) {}

  @override
  void handleCancelBackGesture() {}

  @override
  void handleCommitBackGesture() {}

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    throw UnimplementedError();
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {}
}
