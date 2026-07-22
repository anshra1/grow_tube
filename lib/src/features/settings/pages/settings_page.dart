import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/constants/app_links.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
import 'package:levelup_tube/src/core/widgets/atoms/top_header.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/settings/pages/setting_page_widgets/section_header.dart';
import 'package:levelup_tube/src/features/settings/pages/setting_page_widgets/setting_card.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/setting_state.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/settings_cubit.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static final Uri _privacyPolicyUri = Uri.parse(AppLinks.privacyPolicy);
  Timer? _tapResetTimer;
  int _titleTapCount = 0;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadAllPlaylist();
  }

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    super.dispose();
  }

  void _handleTitleTap() {
    _tapResetTimer?.cancel();
    _titleTapCount += 1;

    if (_titleTapCount >= 5) {
      _titleTapCount = 0;
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (context) => TalkerScreen(talker: talker)));
      return;
    }

    _tapResetTimer = Timer(const Duration(milliseconds: 700), () {
      _titleTapCount = 0;
    });
  }

  Future<void> _handlePrivacyTap() async {
    final launched = await launchUrl(
      _privacyPolicyUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: const Text('Could not open Privacy Policy'),
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTitleTap,
          child: const TopHeaderText('Settings'),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Theme Section ────────────────────────────────────────────────
          const SectionHeader(title: 'Appearance'),
          SliverToBoxAdapter(
            child: SettingsCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    return SegmentedButton<ThemeMode>(
                      segments: ThemeMode.values.map((mode) {
                        final (icon, label) = _themeMeta(mode);
                        return ButtonSegment<ThemeMode>(
                          value: mode,
                          icon: Icon(icon),
                          label: Text(label),
                        );
                      }).toList(),
                      selected: {themeState.mode},
                      onSelectionChanged: (selected) {
                        context.read<ThemeCubit>().setThemeMode(selected.first);
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // ── Default Playlist Section ─────────────────────────────────
          const SectionHeader(title: 'Default Playlist'),
          SliverToBoxAdapter(
            child: SettingsCard(
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  if (state is SettingsLoadingState || state is SettingsInitialState) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSizes.p16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is SettingsErrorState) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Text(
                        'Error loading playlists: ${state.message}',
                        style: TextStyle(color: context.colorScheme.error),
                      ),
                    );
                  }

                  if (state is SettingsLoadedState) {
                    if (state.allPlaylists.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSizes.p16),
                        child: Text('No playlists found. Create one first.'),
                      );
                    }

                    return Column(
                      children: state.allPlaylists.map((playlist) {
                        final isSelected = playlist.id == state.defaultPlaylistId;
                        return ListTile(
                          leading: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              key: ValueKey(isSelected),
                              color: isSelected
                                  ? context.colorScheme.primary
                                  : context.colorScheme.outline,
                            ),
                          ),
                          title: Text(
                            playlist.title,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${playlist.videoCount} video${playlist.videoCount == 1 ? '' : 's'}',
                          ),
                          onTap: () => context.read<SettingsCubit>().setDefaultPlaylist(
                            playlist.id,
                          ),
                        );
                      }).toList(),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // ── Privacy Section ──────────────────────────────────────────
          const SectionHeader(title: 'Privacy'),
          SliverToBoxAdapter(
            child: SettingsCard(
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: _handlePrivacyTap,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.p32)),
        ],
      ),
    );
  }

  (IconData, String) _themeMeta(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => (Icons.light_mode_outlined, 'Light'),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'Dark'),
      ThemeMode.system => (Icons.brightness_auto, 'System (Auto)'),
    };
  }
}
