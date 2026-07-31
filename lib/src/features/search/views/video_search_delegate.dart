import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_page_widgets/playlist_card.dart';
import 'package:levelup_tube/src/features/search/viewmodels/search_cubit.dart';
import 'package:levelup_tube/src/features/search/viewmodels/search_state.dart';
import 'package:levelup_tube/src/features/search/views/search_video_card.dart';

class VideoSearchDelegate extends SearchDelegate<dynamic> {
  VideoSearchDelegate({required this.searchCubit});

  final SearchCubit searchCubit;

  @override
  String get searchFieldLabel => 'Search videos & playlists';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return context.theme.copyWith(
      appBarTheme: context.theme.appBarTheme.copyWith(
        backgroundColor: context.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: context.colorScheme.onSurfaceVariant),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            searchCubit.search('');
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildBody();

  @override
  Widget buildSuggestions(BuildContext context) {
    searchCubit.search(query);
    return _buildBody();
  }

  Widget _buildBody() {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: searchCubit,
      builder: (context, state) {
        if (state is SearchInitial) {
          return Center(
            child: Text(
              'Type to search...',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        } else if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SearchError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: context.colorScheme.error),
            ),
          );
        } else if (state is SearchLoaded) {
          if (state.playlists.isEmpty && state.videos.isEmpty) {
            return Center(
              child: Text(
                'No results found',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p8,
              vertical: AppSizes.p8,
            ),
            children: [
              if (state.playlists.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(AppSizes.p8),
                  child: Text(
                    'Playlists',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
                ...state.playlists.map(
                  (playlist) => PlaylistCard(
                    playlist: playlist,
                    onTap: () => close(context, playlist),
                    onLongPress: () {},
                    onOptionsTap: () {},
                  ),
                ),
              ],
              if (state.videos.isNotEmpty) ...[
                if (state.playlists.isNotEmpty) const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.p8),
                  child: Text(
                    'Videos',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
                ...state.videos.map(
                  (result) => SearchVideoCard(
                    video: result.video.toEntity(),
                    customSubtitle: result.playlistTitle,
                    onTap: () => close(context, result),
                  ),
                ),
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
