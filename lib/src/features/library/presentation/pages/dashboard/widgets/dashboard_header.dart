import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/constants/app_links.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
import 'package:levelup_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  static final Uri _privacyPolicyUri = Uri.parse(AppLinks.privacyPolicy);
  Timer? _tapResetTimer;
  int _titleTapCount = 0;

  void _handleTitleTap() {
    _tapResetTimer?.cancel();
    _titleTapCount += 1;

    if (_titleTapCount >= 3) {
      _titleTapCount = 0;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => TalkerScreen(talker: talker)),
      );
      return;
    }

    _tapResetTimer = Timer(const Duration(milliseconds: 700), () {
      _titleTapCount = 0;
    });
  }

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    super.dispose();
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
        title: const Text(AppStrings.dashboardError),
        description: const Text(
          AppStrings.dashboardUnableToOpenPrivacyPolicy,
        ),
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTitleTap,
            child: Text(
              'LevelUp Tube',
              style: GoogleFonts.oswald(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Row(
            children: [
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) {
                  final (icon, tooltip) = _themeIconAndTooltip(state.mode);
                  return IconButton(
                    onPressed: () => context.read<ThemeCubit>().cycleThemeMode(),
                    icon: Icon(icon),
                    tooltip: tooltip,
                  );
                },
              ),
              PopupMenuButton<_HeaderMenuAction>(
                tooltip: AppStrings.dashboardPrivacyPolicy,
                onSelected: (action) {
                  switch (action) {
                    case _HeaderMenuAction.privacyPolicy:
                      _openPrivacyPolicy();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<_HeaderMenuAction>(
                    value: _HeaderMenuAction.privacyPolicy,
                    child: Text(AppStrings.dashboardPrivacyPolicy),
                  ),
                ],
              ),
              gapW8,
            ],
          ),
        ],
      ),
    );
  }

  (IconData, String) _themeIconAndTooltip(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => (Icons.light_mode, 'Switch to dark mode'),
      ThemeMode.dark => (Icons.dark_mode, 'Switch to light mode'),
      ThemeMode.system => (Icons.light_mode, 'Switch theme'),
    };
  }
}

enum _HeaderMenuAction { privacyPolicy }
