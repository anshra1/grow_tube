import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/dashboard_empty_state.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/video_list_with_player.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_cubit.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_state.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/setting_state.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/settings_cubit.dart';
import 'package:levelup_tube/src/core/widgets/molecules/custom_alert_dialog.dart';
import 'package:toastification/toastification.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardContent();
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlaylistDetailCubit>();
    return MultiBlocListener(
      listeners: [
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) {
            if (previous is SettingsLoadedState && current is SettingsLoadedState) {
              return previous.defaultPlaylistId != current.defaultPlaylistId;
            }
            return previous is! SettingsLoadedState && current is SettingsLoadedState;
          },
          listener: (context, state) {
            context.read<PlaylistDetailCubit>().onDefaultPlaylistChanged();
          },
        ),
        BlocListener<PlaylistDetailCubit, PlaylistDetailState>(
          listener: (context, state) {
            if (state is PlaylistDetailError) {
              toastification.show(
                context: context,
                type: ToastificationType.error,
                style: ToastificationStyle.flatColored,
                title: const Text(AppStrings.dashboardError),
                description: Text(state.message),
                autoCloseDuration: const Duration(seconds: 2),
                alignment: Alignment.bottomCenter,
              );
            }
          },
        ),
      ],
      child: BlocBuilder<PlaylistDetailCubit, PlaylistDetailState>(
        builder: (context, state) {
          return switch (state) {
            PlaylistDetailInitial() || PlaylistDetailLoading() =>
              const VideoListWithPlayer(isLoading: true, isEmpty: false),
            PlaylistDetailEmpty() => VideoListWithPlayer(
              isLoading: false,
              isEmpty: true,
              emptyWidget: DashboardEmptyState(onAddVideo: cubit.addVideo),
              heroPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p8),
              heroShimmerRadius: AppRadius.roundedXL,
            ),
            PlaylistDetailLoaded() => _LoadedDashboardBody(),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  void _showVideoOptionsBottomSheet(BuildContext context, Video video) {
    final cubit = context.read<PlaylistDetailCubit>();
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(video.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(video.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                cubit.setVideoPinned(video.id, !video.isPinned);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showDeleteVideoDialog(context, video);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteVideoDialog(BuildContext context, Video video) {
    final cubit = context.read<PlaylistDetailCubit>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => CustomAlertDialog(
        title: AppStrings.dashboardDeleteTitle,
        content: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: AppStrings.dashboardDeleteConfirm),
              const TextSpan(text: ' '),
              TextSpan(
                text: '"${video.title}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?'),
            ],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        cancelText: AppStrings.commonCancel,
        confirmText: AppStrings.commonDelete,
        onCancel: () => Navigator.of(dialogContext).pop(),
        onConfirm: () {
          cubit.removeVideo(video.id);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}

class _LoadedDashboardBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<PlaylistDetailCubit>();
    // Use BlocSelector for each independent part of the state
    final videosState = context.select<PlaylistDetailCubit, PlaylistVideosState?>(
      (cubit) => cubit.state is PlaylistDetailLoaded
          ? (cubit.state as PlaylistDetailLoaded).videosState
          : null,
    );
    final heroVideoState = context.select<PlaylistDetailCubit, HeroVideoState?>(
      (cubit) => cubit.state is PlaylistDetailLoaded
          ? (cubit.state as PlaylistDetailLoaded).heroVideoState
          : null,
    );

    if (videosState == null || heroVideoState == null) {
      return const SizedBox.shrink();
    }

    return VideoListWithPlayer(
      isLoading: false,
      isEmpty: false,
      videos: videosState.videos,
      heroVideo: heroVideoState.heroVideo,
      forcePlayTimestamp: heroVideoState.forcePlayTimestamp,
      onOptionsTap: (video) {
        context
            .findAncestorWidgetOfExactType<_DashboardContent>()!
            ._showVideoOptionsBottomSheet(context, video);
      },
      heroPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p8),
      heroShimmerRadius: AppRadius.roundedXL,
    );
  }
}
