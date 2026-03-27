import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/constants/app_icons.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
import 'package:levelup_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'LevelUp Tube',
            style: GoogleFonts.oswald(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface,
              letterSpacing: -0.5,
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
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TalkerScreen(talker: talker)),
                ),
                icon: const Icon(AppIcons.bug),
                tooltip: AppStrings.dashboardViewLogs,
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
      ThemeMode.system => (Icons.brightness_auto, 'Switch to light mode'),
      ThemeMode.light => (Icons.light_mode, 'Switch to dark mode'),
      ThemeMode.dark => (Icons.dark_mode, 'Switch to system theme'),
    };
  }
}
