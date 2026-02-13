import 'package:flutter/material.dart';
import 'package:skill_tube/main.dart';
import 'package:skill_tube/src/core/constants/app_icons.dart';
import 'package:skill_tube/src/core/constants/app_strings.dart';
import 'package:skill_tube/src/core/design_system/app_colors.dart';
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.dashboardGreeting,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              gapH4,
              Text(
                AppStrings.dashboardUserName,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TalkerScreen(talker: talker),
                  ),
                ),
                icon: const Icon(AppIcons.bug),
                tooltip: AppStrings.dashboardViewLogs,
              ),
              gapW8,
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colorScheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuClOSBU8sYOvchtWleaLNnJxhF5JnRFnuG7vJym5QUdO_hqJOVDCdS6tDTG1OSldUdWLNn0Nm9SY9qZ8DW9VAXqQXHTqT0Uuzls4Jba50fHFD6j51sGi_kn9tSaC1nVrPCHHm1uvDh-8hHss43gwby3NsFfstjZLZ_qqyzgQiPAv6fxp6I1CaT9KSAeLblwQP-0zejPvtRyqe-nMPKHz86BZyOTO1KKAQOXU_tFegN_Jhzbw6M-nxg2WFiYKyD-cXCRhMM-F6J1wFw',
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: context.colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
