import 'package:flutter/material.dart';
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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial fetch
    context.read<LibraryBloc>().add(const LibraryInitializedEvent());

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const DashboardHeader(),
            Expanded(
              child: BlocConsumer<LibraryBloc, LibraryState>(
                listener: (context, state) {
                  if (state is LibraryFailureState) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(
                      content: Text('${AppStrings.dashboardError}: ${state.message}'),
                      backgroundColor: context.colorScheme.error,
                    ));
                  }
                },
                builder: (context, state) {
                  if (state is LibraryLoadingState && state is! LibraryLoadedState) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: context.colorScheme.primary,
                      ),
                    );
                  }

                  if (state is LibraryFailureState) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: context.colorScheme.error),
                      ),
                    );
                  }

                  if (state is LibraryEmptyState) {
                    return Center(
                      child: Text(
                        AppStrings.dashboardNoVideos,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  if (state is LibraryLoadedState) {
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
                            child: Column(
                              children: [
                                if (state.heroVideo != null) ...[
                                  gapH24,
                                  DashboardHero(video: state.heroVideo!),
                                ],
                                gapH32,
                              ],
                            ),
                          ),
                        ),
                        DashboardVideoList(videos: state.videos),
                        const SliverToBoxAdapter(child: gapH48),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
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
