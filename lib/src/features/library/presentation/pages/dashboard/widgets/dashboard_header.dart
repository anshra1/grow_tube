import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/design_system/app_colors.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/design_system/app_typography.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(
        left: AppSizes.p24,
        right: AppSizes.p24,
        top: AppSizes.p12, // Reduced top padding due to SafeArea
        bottom: AppSizes.p16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Evening,',
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              gapH4,
              Text(
                'Alex', // Hardcoded user name for now
                style: AppTypography.h2.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
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
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.background,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
