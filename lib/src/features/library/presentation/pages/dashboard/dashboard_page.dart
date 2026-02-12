import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:skill_tube/src/core/widgets/app_scaffold.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_state.dart';
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
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  if (state is LibraryLoadingState && state is! LibraryLoadedState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is LibraryFailureState) {
                    return Center(child: Text(state.message));
                  }

                  if (state is LibraryEmptyState) {
                    // TODO: Implement Empty State Widget
                    return const Center(child: Text('No videos yet. Add one!'));
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
          // TODO: Open Add Video Modal
          // For now, just a placeholder or debug add
          // context.read<LibraryBloc>().add(const LibraryVideoAddedEvent('https://youtu.be/...'));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
