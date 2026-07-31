import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/search_cubit.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/search_state.dart';

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
            children: [
              if (state.playlists.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Text(
                    'Playlists',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
                ...state.playlists.map((playlist) => ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerHighest,
                          borderRadius: AppRadius.roundedS,
                        ),
                        child: Icon(
                          Icons.playlist_play,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(
                        playlist.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text('${playlist.videoCount} videos'),
                      onTap: () => close(context, playlist),
                    )),
              ],
              if (state.videos.isNotEmpty) ...[
                if (state.playlists.isNotEmpty) const Divider(),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Text(
                    'Videos',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
                ...state.videos.map((result) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                        vertical: AppSizes.p8,
                      ),
                      leading: SizedBox(
                        width: 90,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: AppRadius.roundedS,
                          child: CachedNetworkImage(
                            imageUrl: result.video.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => ColoredBox(
                              color: context.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.video_library),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        result.video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.video.channelName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                result.playlistTitle,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () => close(context, result),
                    )),
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
