import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    this.imageUrl,
    this.height = 400,
    super.key,
  });

  final String? imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: imageUrl != null
            ? _buildBlurredImage(context, imageUrl!)
            : const SizedBox.shrink(key: ValueKey('empty_bg')),
      ),
    );
  }

  Widget _buildBlurredImage(BuildContext context, String url) {
    final backgroundColor = Theme.of(context).colorScheme.surface;
    
    return Stack(
      key: ValueKey(url),
      fit: StackFit.expand,
      children: [
        // 1 & 2. The base image with a heavy blur effect
        Opacity(
          opacity: 0.5, // Darken it so text remains readable
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80, tileMode: TileMode.decal),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          ),
        ),
        
        // 3. The gradient fade out to the app's surface color
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                backgroundColor.withValues(alpha: 0.1),
                backgroundColor.withValues(alpha: 0.6),
                backgroundColor,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
