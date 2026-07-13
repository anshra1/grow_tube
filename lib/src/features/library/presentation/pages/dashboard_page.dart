import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/widgets/pages/app_scaffold.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_state.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/widgets/dashboard_empty_state.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/widgets/dashboard_video_list.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/widgets/dashboard_video_list_shimmer.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/widgets/dashboard_video_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: _DashboardContent(),
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
          const SizedBox(height: AppSizes.p8),
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
                    DashboardVideoPlayer(
                      video: state.lastPlayVideo!,
                      forcePlayTimestamp: state.forcePlayTimestamp,
                    ),
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
