import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';

class DraggableFab extends StatefulWidget {
  const DraggableFab({
    required this.child,
    this.initialOffset,
    super.key,
  });

  final Widget child;
  final Offset? initialOffset;

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  late Offset _offset;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final size = MediaQuery.of(context).size;
      if (size.width > 0 && size.height > 0) {
        if (widget.initialOffset != null) {
          _offset = widget.initialOffset!;
        } else {
          // Default to a position that doesn't overlap with standard FABs
          // (Usually bottom-right is Offset(size.width - 72, size.height - 100))
          // We'll put it slightly higher.
          _offset = Offset(size.width - 80, size.height - 200);
        }
        _isInitialized = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    const fabSize = AppSizes.fabSize;

    // Ensure the FAB stays within screen bounds even when screen size changes (e.g. keyboard)
    final clampedX = _offset.dx.clamp(0.0, size.width - fabSize);
    final clampedY = _offset.dy.clamp(0.0, size.height - fabSize);

    return Positioned(
      left: clampedX,
      top: clampedY,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        child: widget.child,
      ),
    );
  }
}
