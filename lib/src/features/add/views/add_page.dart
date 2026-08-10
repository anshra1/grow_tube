import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/core/widgets/molecules/app_info_toast.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_cubit.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_state.dart';
import 'package:levelup_tube/src/features/add/views/widgets/add_hero_banner.dart';
import 'package:levelup_tube/src/features/add/views/widgets/add_video_form.dart';
import 'package:levelup_tube/src/features/add/views/widgets/create_playlist_form.dart';
import 'package:levelup_tube/src/features/add/views/widgets/import_playlist_form.dart';
import 'package:levelup_tube/src/features/add/views/widgets/tab_option_card.dart';
import 'package:toastification/toastification.dart';

class AddPage extends StatefulWidget {
  const AddPage({this.initialTab = 0, super.key});

  final int initialTab;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late int _selectedTab;

  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _playlistNameController = TextEditingController();
  final TextEditingController _importUrlController = TextEditingController();

  final ValueNotifier<int?> _selectedPlaylistIdNotifier = ValueNotifier<int?>(null);
  final ValueNotifier<String?> _imageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    context.read<AddCubit>().loadPlaylists();
  }

  @override
  void dispose() {
    _videoUrlController.dispose();
    _playlistNameController.dispose();
    _importUrlController.dispose();
    _selectedPlaylistIdNotifier.dispose();
    _imageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCubit, AddState>(
      listenWhen: (previous, current) {
        return current is AddVideoSuccess ||
            current is CreatePlaylistSuccess ||
            current is ImportPlaylistSuccess ||
            current is AddError;
      },
      listener: (context, state) {
        if (state is AddVideoSuccess) {
          _videoUrlController.clear();
          _selectedPlaylistIdNotifier.value = null;
          _showActionToast(
            context,
            'Video added successfully.',
            'WATCH',
            () => context.go('/playlists/${state.playlistId}', extra: state.videoUrl),
          );
        } else if (state is CreatePlaylistSuccess) {
          _playlistNameController.clear();
          _imageNotifier.value = null;
          _showToast(
            context,
            'Success!',
            'Playlist created successfully.',
            ToastificationType.success,
          );
        } else if (state is ImportPlaylistSuccess) {
          _importUrlController.clear();
          _showActionToast(
            context,
            'Playlist imported successfully.',
            'OPEN',
            () => context.go('/playlists/${state.playlistId}'),
          );
        } else if (state is AddError) {
          FocusManager.instance.primaryFocus?.unfocus();
          _showToast(context, 'Error!', state.message, ToastificationType.error);
        }
      },
      child: AppScaffold(
        // appBar: AppBar(
        //   title: const Text(
        //     'Add',
        //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //   ),
        // ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AddHeroBanner(),
              const Gap(32),
              Row(
                children: [
                  TabOptionCard(
                    icon: Icons.video_call_outlined,
                    label: 'Add\nVideo',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  const Gap(12),
                  TabOptionCard(
                    icon: Icons.create_new_folder_outlined,
                    label: 'Create\nPlaylist',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                  const Gap(12),
                  TabOptionCard(
                    icon: Icons.download_outlined,
                    label: 'Import\nPlaylist',
                    isSelected: _selectedTab == 2,
                    onTap: () => setState(() => _selectedTab = 2),
                  ),
                ],
              ),
              const Gap(32),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        ...previousChildren.map(
                          (child) => Positioned(top: 0, left: 0, right: 0, child: child),
                        ),
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildSelectedForm(),
                ),
              ),
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedForm() {
    switch (_selectedTab) {
      case 0:
        return AddVideoForm(
          key: const ValueKey('AddVideoForm'),
          urlController: _videoUrlController,
          selectedPlaylistIdNotifier: _selectedPlaylistIdNotifier,
        );
      case 1:
        return CreatePlaylistForm(
          key: const ValueKey('CreatePlaylistForm'),
          nameController: _playlistNameController,
          imageNotifier: _imageNotifier,
        );
      case 2:
        return ImportPlaylistForm(
          key: const ValueKey('ImportPlaylistForm'),
          urlController: _importUrlController,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showToast(
    BuildContext context,
    String title,
    String description,
    ToastificationType type,
  ) {
    toastification.showCustom(
      context: context,
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.bottomCenter,
      dismissDirection: DismissDirection.horizontal,
      builder: (context, holder) {
        return AppInfoToast(
          title: title,
          subtitle: description,
          icon: type == ToastificationType.error
              ? Icons.error_outline
              : Icons.check_circle_outline,
          isError: type == ToastificationType.error,
          onClose: () => toastification.dismissById(holder.id),
        );
      },
    );
  }

  void _showActionToast(
    BuildContext context,
    String title,
    String actionLabel,
    VoidCallback onAction,
  ) {
    toastification.showCustom(
      context: context,
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.bottomCenter,
      dismissDirection: DismissDirection.horizontal,
      builder: (context, holder) {
        return AppInfoToast(
          title: 'Success!',
          subtitle: title,
          icon: Icons.check_circle_outline,
          actionLabel: actionLabel,
          onAction: () {
            toastification.dismissById(holder.id);
            onAction();
          },
          onClose: () => toastification.dismissById(holder.id),
        );
      },
    );
  }
}
