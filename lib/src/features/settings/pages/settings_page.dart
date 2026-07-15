import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/constants/app_links.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
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
  static final Uri _privacyPolicyUri = Uri.parse(
    AppLinks.privacyPolicy,
  );

  // Hidden developer menu — 3 taps on Privacy Policy within 700ms window
  Timer? _tapResetTimer;
  int _privacyTapCount = 0;

  // Crashlytics testing
  bool _showCrashlytics = false;
  bool _crashlyticsEnabled = true;
  final TextEditingController _userIdController =
      TextEditingController();
  final TextEditingController _customKeyController =
      TextEditingController();
  final TextEditingController _customValueController =
      TextEditingController();
  final AppLogger _logger = sl<AppLogger>();

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
    _loadCrashlyticsStatus();
  }

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    _userIdController.dispose();
    _customKeyController.dispose();
    _customValueController.dispose();
    super.dispose();
  }

  Future<void> _loadCrashlyticsStatus() async {
    final enabled = await _logger.isCrashlyticsCollectionEnabled();
    setState(() {
      _crashlyticsEnabled = enabled;
    });
  }

  void _handlePrivacyTap() {
    _tapResetTimer?.cancel();
    _privacyTapCount += 1;

    if (_privacyTapCount >= 3) {
      _privacyTapCount = 0;
      setState(() {
        _showCrashlytics = !_showCrashlytics;
      });
      if (!_showCrashlytics) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TalkerScreen(talker: talker),
          ),
        );
      }
      return;
    }

    _openPrivacyPolicy();

    _tapResetTimer = Timer(const Duration(milliseconds: 700), () {
      _privacyTapCount = 0;
    });
  }

  Future<void> _openPrivacyPolicy() async {
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

  // Crashlytics methods
  Future<void> _toggleCrashlytics(bool value) async {
    await _logger.setCrashlyticsCollectionEnabled(enabled: value);
    setState(() {
      _crashlyticsEnabled = value;
    });
    if (mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: Text('Crashlytics ${value ? 'enabled' : 'disabled'}'),
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  void _setUserId() {
    final userId = _userIdController.text.trim();
    if (userId.isNotEmpty) {
      _logger.setUserIdentifier(userId);
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: const Text('User ID set'),
          autoCloseDuration: const Duration(seconds: 2),
          alignment: Alignment.bottomCenter,
        );
      }
    }
  }

  void _clearUserId() {
    _logger.clearUserIdentifier();
    _userIdController.clear();
    if (mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: const Text('User ID cleared'),
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  void _setCustomKey() {
    final key = _customKeyController.text.trim();
    final value = _customValueController.text.trim();
    if (key.isNotEmpty && value.isNotEmpty) {
      _logger.setCustomKey(key, value);
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: const Text('Custom key set'),
          autoCloseDuration: const Duration(seconds: 2),
          alignment: Alignment.bottomCenter,
        );
      }
    }
  }

  void _testNonFatalError() {
    try {
      throw Exception('Test non-fatal error from settings');
    } on Exception catch (e, stack) {
      _logger.handle(e, stack, 'Test non-fatal error triggered');
    }
    if (mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.info,
        style: ToastificationStyle.fillColored,
        title: const Text('Non-fatal error recorded'),
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  Future<void> _testFatalError() async {
    try {
      throw StateError('Test fatal error from settings');
    } on Exception catch (e, stack) {
      await _logger.recordFatalError(
        e,
        stack,
        reason: 'Test fatal error triggered',
      );
    }
    if (mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.info,
        style: ToastificationStyle.fillColored,
        title: const Text('Fatal error recorded'),
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  Future<void> _sendUnsentReports() async {
    await _logger.sendUnsentReports();
    if (mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: const Text('Reports sent'),
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  Future<void> _deleteUnsentReports() async {
    await _logger.deleteUnsentReports();
    if (mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: const Text('Reports deleted'),
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.p16,
                  AppSizes.p24,
                  AppSizes.p16,
                  AppSizes.p8,
                ),
                child: Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // ── Theme Section ────────────────────────────────────────────────
            const _SectionHeader(title: 'Appearance'),
            SliverToBoxAdapter(
              child: _SettingsCard(
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
                          context.read<ThemeCubit>().setThemeMode(
                            selected.first,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Default Playlist Section ─────────────────────────────────
            const _SectionHeader(title: 'Default Playlist'),
            SliverToBoxAdapter(
              child: _SettingsCard(
                child: BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    if (state is SettingsLoadingState ||
                        state is SettingsInitialState) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSizes.p16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state is SettingsErrorState) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Text(
                          'Error loading playlists: ${state.message}',
                          style: TextStyle(
                            color: context.colorScheme.error,
                          ),
                        ),
                      );
                    }

                    if (state is SettingsLoadedState) {
                      if (state.allPlaylists.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSizes.p16),
                          child: Text(
                            'No playlists found. Create one first.',
                          ),
                        );
                      }

                      return Column(
                        children: state.allPlaylists.map((playlist) {
                          final isSelected =
                              playlist.id == state.defaultPlaylistId;
                          return ListTile(
                            leading: AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 200,
                              ),
                              child: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
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
                            onTap: () => context
                                .read<SettingsCubit>()
                                .setDefaultPlaylist(playlist.id),
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
            const _SectionHeader(title: 'Privacy'),
            SliverToBoxAdapter(
              child: _SettingsCard(
                child: ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: _handlePrivacyTap,
                ),
              ),
            ),

            // ── Crashlytics Testing Section (hidden) ───────────────────────
            if (_showCrashlytics) ...[
              const _SectionHeader(title: 'Crashlytics Testing'),
              SliverToBoxAdapter(
                child: _SettingsCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Crashlytics enabled toggle
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Crashlytics Enabled'),
                            Switch(
                              value: _crashlyticsEnabled,
                              onChanged: _toggleCrashlytics,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // User ID
                        const Text('User ID'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _userIdController,
                          decoration: InputDecoration(
                            hintText: 'Enter user ID',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearUserId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _setUserId,
                          child: const Text('Set User ID'),
                        ),
                        const SizedBox(height: 16),

                        // Custom key/value
                        const Text('Custom Key'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _customKeyController,
                          decoration: const InputDecoration(
                            hintText: 'Enter key',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _customValueController,
                          decoration: const InputDecoration(
                            hintText: 'Enter value',
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _setCustomKey,
                          child: const Text('Set Custom Key'),
                        ),
                        const SizedBox(height: 16),

                        // Test errors
                        const Text('Test Errors'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _testNonFatalError,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                ),
                                child: const Text('Non-Fatal Error'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _testFatalError,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Fatal Error'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Reports management
                        const Text('Reports'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _sendUnsentReports,
                                child: const Text('Send Reports'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _deleteUnsentReports,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete Reports'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.p32),
            ),
          ],
        ),
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

// ---------------------------------------------------------------------------
// Local helper widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.p16,
          AppSizes.p16,
          AppSizes.p16,
          AppSizes.p8,
        ),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: context.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Card(
        elevation: 0,
        color: context.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
