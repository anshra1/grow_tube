import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_shadows.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.padding,
    this.height,
    this.width,
    this.showBorder = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: AppRadius.roundedL,
        border: showBorder
            ? Border.all(
                color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
              )
            : null,
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: context.colorScheme.surface,
        borderRadius: AppRadius.roundedL,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: AppRadius.roundedL,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return context.colorScheme.primary.withValues(alpha: 0.12);
            }
            return null;
          }),
          onTap: onTap != null
              ? () {
                  Feedback.forTap(context);
                  HapticFeedback.heavyImpact();
                  HapticFeedback.vibrate();
                  onTap!();
                }
              : null,
          onLongPress: onLongPress,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
