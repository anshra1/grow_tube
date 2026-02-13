import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_tube/src/core/constants/app_icons.dart';
import 'package:skill_tube/src/core/constants/app_strings.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:skill_tube/src/core/widgets/app_scaffold.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_state.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/add_video_bottom_sheet.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_header.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_hero.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_video_list.dart';
import 'package:toastification/toastification.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Enforce portrait mode for the dashboard
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const DashboardHeader(),
            Expanded(
              child: BlocConsumer<LibraryBloc, LibraryState>(
                buildWhen: (previous, current) =>
                    current is LibraryLoadedState ||
                    current is LibraryEmptyState ||
                    (current is LibraryLoadingState && previous is LibraryInitialState),
                listener: (context, state) {
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
                    default:
                      break;
                  }
                },
                builder: (context, state) {
                  return switch (state) {
                    LibraryInitialState() || LibraryLoadingState() => Center(
                      child: CircularProgressIndicator(
                        color: context.colorScheme.primary,
                      ),
                    ),
                    LibraryFailureState(:final message) => Center(
                      child: Text(
                        message,
                        style: TextStyle(color: context.colorScheme.error),
                      ),
                    ),
                    LibraryEmptyState() => Center(
                      child: Text(
                        AppStrings.dashboardNoVideos,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    LibraryLoadedState(:final videos, :final heroVideo) => Column(
                      children: [
                        if (heroVideo != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                            child: Column(
                              children: [
                                gapH16,
                                DashboardHero(video: heroVideo),
                                gapH16,
                              ],
                            ),
                          ),
                        Expanded(
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              DashboardVideoList(videos: videos),
                              const SliverToBoxAdapter(child: gapH48),
                            ],
                          ),
                        ),
                      ],
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
