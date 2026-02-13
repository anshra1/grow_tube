import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_tube/main.dart';
import 'package:skill_tube/src/core/constants/app_icons.dart';
import 'package:skill_tube/src/core/constants/app_strings.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'GrowTube',
            style: GoogleFonts.oswald(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
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
}
