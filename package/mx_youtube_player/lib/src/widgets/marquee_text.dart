import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final double pauseDuration;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(seconds: 10),
    this.pauseDuration = 2.0,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    while (mounted) {
      if (!_scrollController.hasClients) break;

      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) break; // No need to scroll

      await Future.delayed(Duration(seconds: widget.pauseDuration.toInt()));
      if (!mounted) break;

      await _scrollController.animateTo(
        maxScroll,
        duration: widget.duration,
        curve: Curves.linear,
      );
      if (!mounted) break;

      await Future.delayed(Duration(seconds: widget.pauseDuration.toInt()));
      if (!mounted) break;

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(widget.text, style: widget.style),
    );
  }
}
