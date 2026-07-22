import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_button_state.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';
import 'package:levelup_tube/src/core/widgets/atoms/top_header.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/library/views/add_page_widgets/get_youtube_url.dart';
import 'package:levelup_tube/src/features/library/views/add_page_widgets/select_playlist.dart';
import 'package:levelup_tube/src/features/library/views/add_page_widgets/top_header.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_cubit.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_state.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/setting_state.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/settings_cubit.dart';
import 'package:toastification/toastification.dart';

class AddVideo extends StatefulWidget {
  const AddVideo({super.key});

  @override
  State<AddVideo> createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> {
  final TextEditingController _urlController = TextEditingController();
  final ValueNotifier<int?> _selectedPlaylistIdNotifier = ValueNotifier<int?>(null);

  @override
  void initState() {
    context.read<SettingsCubit>().loadAllPlaylist();
    super.initState();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _selectedPlaylistIdNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<PlaylistDetailCubit, PlaylistDetailState>(
      listener: (context, state) {
        if (state is VideoAddPlaylistSuccessState) {
          _urlController.clear();
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            title: const Text('Success!'),
            description: const Text('Video added successfully!'),
            autoCloseDuration: const Duration(seconds: 4),
            alignment: Alignment.bottomCenter,
          );
        } else if (state is PlaylistDetailError) {
          FocusManager.instance.primaryFocus?.unfocus();
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            title: const Text('Error!'),
            description: Text(state.message),
            autoCloseDuration: const Duration(seconds: 4),
            alignment: Alignment.bottomCenter,
          );
        }
      },

      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final playlists = settingsState is SettingsLoadedState
              ? settingsState.allPlaylists
              : <PlaylistModel>[];

          // Set default playlist id when settings state loads
          if (settingsState is SettingsLoadedState &&
              _selectedPlaylistIdNotifier.value == null) {
            _selectedPlaylistIdNotifier.value = settingsState.defaultPlaylistId;
          }

          return AppScaffold(
            appBar: AppBar(title: const TopHeaderText('Add Video Link')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TopHeader(),
                  const Gap(32),
                  GetYoutubeUrl(urlController: _urlController, theme: theme),
                  const Gap(24),
                  SelectPlaylist(
                    selectedPlaylistIdNotifier: _selectedPlaylistIdNotifier,
                    playlists: playlists,
                  ),
                  const Gap(32),
                  ListenableBuilder(
                    listenable: Listenable.merge([
                      _urlController,
                      _selectedPlaylistIdNotifier,
                    ]),
                    builder: (context, child) {
                      return BlocBuilder<PlaylistDetailCubit, PlaylistDetailState>(
                        builder: (context, playlistState) {
                          final isAdding = playlistState is PlaylistDetailLoading;

                          final isEnabled =
                              _urlController.text.trim().isNotEmpty &&
                              _selectedPlaylistIdNotifier.value != null &&
                              !isAdding;

                          AppButtonState buttonState;
                          if (isAdding) {
                            buttonState = AppButtonState.loading;
                          } else if (isEnabled) {
                            buttonState = AppButtonState.enabled;
                          } else {
                            buttonState = AppButtonState.disabled;
                          }

                          return AppPrimaryButton(
                            state: buttonState,
                            onPressed: isEnabled
                                ? () {
                                    context
                                        .read<PlaylistDetailCubit>()
                                        .addVideoToPlaylist(
                                          _selectedPlaylistIdNotifier.value!,
                                          _urlController.text.trim(),
                                        );
                                  }
                                : null,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: const Text(
                              'Add Video',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
