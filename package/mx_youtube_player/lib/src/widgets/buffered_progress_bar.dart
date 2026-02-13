import 'package:flutter/material.dart';

class BufferedProgressBar extends StatelessWidget {
  final double position;
  final double buffered;
  final double duration;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final Color activeColor;
  final Color bufferedColor;
  final Color backgroundColor;

  const BufferedProgressBar({
    super.key,
    required this.position,
    required this.buffered,
    required this.duration,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.activeColor = Colors.orange,
    this.bufferedColor = Colors.white30,
    this.backgroundColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    final max = duration > 0 ? duration : 1.0;
    final bufferedValue = (buffered / max).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 20,
          width: constraints.maxWidth,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background Track
              Container(height: 2, width: constraints.maxWidth, color: backgroundColor),

              // Buffered Track
              FractionallySizedBox(
                widthFactor: bufferedValue,
                child: Container(height: 2, color: bufferedColor),
              ),

              // Slider (Active Track + Thumb)
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: activeColor,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: activeColor,
                  trackHeight: 2.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                ),
                child: Slider(
                  value: position.clamp(0.0, max),
                  min: 0,
                  max: max,
                  onChanged: onChanged,
                  onChangeStart: onChangeStart,
                  onChangeEnd: onChangeEnd,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
