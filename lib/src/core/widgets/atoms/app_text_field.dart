import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.cornerRadius,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final BorderRadius? cornerRadius;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    final border = OutlineInputBorder(
      borderRadius: cornerRadius ?? AppRadius.roundedL,
      borderSide: BorderSide(
        color: hasError ? context.colorScheme.error : context.colorScheme.outlineVariant,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: cornerRadius ?? AppRadius.roundedL,
      borderSide: BorderSide(
        color: hasError ? context.colorScheme.error : context.colorScheme.primary,
        width: 2,
      ),
    );

    final disabledBorder = OutlineInputBorder(
      borderRadius: cornerRadius ?? AppRadius.roundedL,
      borderSide: BorderSide(
        color: context.colorScheme.onSurface.withValues(alpha: 0.12),
      ),
    );

    var prefix = prefixWidget;
    if (prefixIcon != null) {
      prefix ??= Icon(
        prefixIcon,
        color: hasError
            ? context.colorScheme.error
            : context.colorScheme.onSurfaceVariant,
        size: AppIconSizes.md,
      );
    }

    var suffix = suffixWidget;
    if (suffixIcon != null) {
      suffix ??= Icon(
        suffixIcon,
        color: hasError
            ? context.colorScheme.error
            : context.colorScheme.onSurfaceVariant,
        size: AppIconSizes.md,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.p8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          minLines: minLines,
          maxLines: maxLines,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          validator: validator,
          style: context.textTheme.bodyLarge?.copyWith(
            color: enabled
                ? context.colorScheme.onSurface
                : context.colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            errorText: errorText,
            prefixIcon: prefix != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
                    child: prefix,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: AppIconSizes.md + AppSizes.p24,
            ),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
                    child: suffix,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: AppIconSizes.md + AppSizes.p24,
            ),
            filled: true,
            fillColor: enabled
                ? context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : context.colorScheme.onSurface.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16,
              vertical: AppSizes.p16,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder,
            disabledBorder: disabledBorder,
            errorBorder: border.copyWith(
              borderSide: BorderSide(color: context.colorScheme.error),
            ),
            focusedErrorBorder: focusedBorder.copyWith(
              borderSide: BorderSide(color: context.colorScheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
