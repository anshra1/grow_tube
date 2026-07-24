import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';

class TopHeaderText extends StatelessWidget {
  const TopHeaderText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: context.colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
    );
  }
}
