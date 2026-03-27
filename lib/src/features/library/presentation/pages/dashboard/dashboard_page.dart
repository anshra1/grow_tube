import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/constants/app_icons.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/mixins/clipboard_monitor_mixin.dart';
import 'package:levelup_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/widgets/app_scaffold.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_state.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/dashboard/widgets/add_video_bottom_sheet.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/dashboard/widgets/clipboard_video_prompt.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_empty_state.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_header.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_video_list.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_video_list_shimmer.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_video_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver, ClipboardMonitorMixin {
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
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: const _DashboardContent(),
      floatingActionButton: BlocBuilder<LibraryBloc, LibraryState>(
        buildWhen: (previous, current) =>
            current is LibraryEmptyState || current is LibraryVideoLoadedState,
        builder: (context, state) {
          if (state is LibraryEmptyState) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
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
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibraryBloc, LibraryState>(
      listener: (context, state) {
        if (state is LibraryFailureState) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            title: Text(AppStrings.dashboardError),
            description: Text(state.message),
            autoCloseDuration: const Duration(seconds: 4),
            alignment: Alignment.bottomCenter,
          );
        }
      },
      child: Column(
        children: [
          const DashboardHeader(),
          const SizedBox(height: AppSizes.p16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            // Smart Player Component
            child: BlocBuilder<LibraryBloc, LibraryState>(
              buildWhen: (previous, current) {
                return current is LibraryVideoLoadedState ||
                    current is LibraryInitialState ||
                    current is LibraryEmptyState;
              },
              builder: (context, state) {
                return switch (state) {
                  LibraryInitialState() => AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Shimmer.fromColors(
                      baseColor: context.colorScheme.surfaceContainerHighest,
                        highlightColor: context.colorScheme.surface,
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.colorScheme.surface,
                            borderRadius: AppRadius.roundedXL,
                          ),
                        ),
                      ),
                    ),
                  LibraryVideoLoadedState() when state.lastPlayVideo != null =>
                    DashboardVideoPlayer(video: state.lastPlayVideo!),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          Expanded(
            // Smart List Component
            child: BlocBuilder<LibraryBloc, LibraryState>(
              buildWhen: (previous, current) {
                return current is LibraryVideoLoadedState ||
                    current is LibraryEmptyState ||
                    current is LibraryInitialState;
              },
              builder: (context, state) {
                return switch (state) {
                  LibraryInitialState() => const DashboardVideoListShimmer(),
                  LibraryEmptyState() => DashboardEmptyState(
                    onAddVideo: (url) {
                      context.read<LibraryBloc>().add(LibraryVideoAddedEvent(url));
                    },
                  ),
                  LibraryVideoLoadedState() => DashboardVideoList(
                    videos: state.libraryVideos,
                  ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
