import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
import 'package:levelup_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
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
