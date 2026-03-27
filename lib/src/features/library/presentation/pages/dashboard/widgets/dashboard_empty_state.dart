import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';

class DashboardEmptyState extends StatefulWidget {
  const DashboardEmptyState({required this.onAddVideo, super.key});

  final ValueChanged<String> onAddVideo;

  @override
  State<DashboardEmptyState> createState() => _DashboardEmptyStateState();
}

class _DashboardEmptyStateState extends State<DashboardEmptyState>
    with TickerProviderStateMixin {
  final _urlController = TextEditingController();
  final _inputSectionKey = GlobalKey();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  // --- Animation Controllers ---
  late final AnimationController _staggerController;
  late final AnimationController _characterBounceController;
  late final AnimationController _blobPulseController;

  // --- Stagger Animations ---
  late final Animation<double> _illustrationFadeAnim;
  late final Animation<Offset> _illustrationSlideAnim;

  late final Animation<double> _textFadeAnim;
  late final Animation<Offset> _textSlideAnim;

  late final Animation<double> _inputFadeAnim;
  late final Animation<Offset> _inputSlideAnim;

  // --- Continuous animations ---
  late final Animation<double> _bounceAnim;
  late final Animation<double> _blobScaleAnim;

  @override
  void initState() {
    super.initState();

    // Stagger: total 1200ms
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Illustration: 0.0 – 0.4
    _illustrationFadeAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _illustrationSlideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
          ),
        );

    // Text area: 0.25 – 0.65
    _textFadeAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
    );
    _textSlideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );

    // Input area: 0.5 – 1.0
    _inputFadeAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _inputSlideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );

    // Character gentle bounce (continuous)
    _characterBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _bounceAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _characterBounceController, curve: Curves.easeInOut),
    );

    // Blob pulse (continuous)
    _blobPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _blobScaleAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _blobPulseController, curve: Curves.easeInOut));

    // Focus listener: scroll input into view when keyboard opens
    _focusNode.addListener(_onFocusChanged);

    // Start animations
    _staggerController.forward();
    _characterBounceController.repeat(reverse: true);
    _blobPulseController.repeat(reverse: true);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      // Wait for the keyboard to fully animate open
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _submit() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      widget.onAddVideo(url);
      _urlController.clear();
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _urlController.text = data.text!;
      _urlController.selection = TextSelection.fromPosition(
        TextPosition(offset: _urlController.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final verticalPadding = keyboardInset > 0 ? AppSizes.p16 : screenHeight * 0.1;
    final scrollPhysics =
        keyboardInset > 0 ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset + 12),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: scrollPhysics,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSizes.p24,
            right: AppSizes.p24,
            top: verticalPadding,
            bottom: verticalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Illustration Section ──
              SlideTransition(
                position: _illustrationSlideAnim,
                child: FadeTransition(
                  opacity: _illustrationFadeAnim,
                  child: _buildIllustrationSection(colors),
                ),
              ),

              gapH16,

              // ── Text Section ──
              SlideTransition(
                position: _textSlideAnim,
                child: FadeTransition(
                  opacity: _textFadeAnim,
                  child: _buildTextSection(colors),
                ),
              ),

              gapH16,

              // ── Input + CTA Section ──
              SlideTransition(
                position: _inputSlideAnim,
                child: FadeTransition(
                  opacity: _inputFadeAnim,
                  child: _buildInputSection(colors),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  Illustration: Blob Character + Clapperboard
  // ════════════════════════════════════════════════════════════════
  Widget _buildIllustrationSection(ColorScheme colors) {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── Pulsing glow behind character ──
          AnimatedBuilder(
            animation: _blobScaleAnim,
            builder: (context, child) {
              return Transform.scale(scale: _blobScaleAnim.value, child: child);
            },
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.tertiaryContainer.withValues(alpha: 0.2),
                boxShadow: [
                  BoxShadow(
                    color: colors.tertiaryContainer.withValues(alpha: 0.15),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // ── Bouncing character blob ──
          AnimatedBuilder(
            animation: _bounceAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceAnim.value),
                child: child,
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The organic blob shape
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.elliptical(80, 80),
                      topRight: Radius.elliptical(120, 100),
                      bottomLeft: Radius.elliptical(140, 120),
                      bottomRight: Radius.elliptical(60, 100),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.tertiaryContainer.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(child: _buildHappyFace(colors)),
                ),

                // ── Movie Clapperboard ──
                Positioned(
                  bottom: -16,
                  right: -16,
                  child: Transform.rotate(
                    angle: 12 * math.pi / 180,
                    child: _buildClapperboard(colors),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Happy face inside the blob
  Widget _buildHappyFace(ColorScheme colors) {
    final faceColor = colors.onTertiaryContainer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Eyes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 16,
              decoration: BoxDecoration(
                color: faceColor,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(width: 28),
            Container(
              width: 10,
              height: 16,
              decoration: BoxDecoration(
                color: faceColor,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Smile
        Container(
          width: 48,
          height: 24,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: faceColor, width: 3.5)),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
      ],
    );
  }

  /// Clapperboard widget
  Widget _buildClapperboard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: colors.onSurface,
        borderRadius: AppRadius.roundedL,
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        width: 56,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.surface, width: 1.5),
            borderRadius: AppRadius.roundedS,
          ),
          child: Column(
            children: [
              // Top stripe bar of the clapperboard
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: AppRadius.radiusS,
                    topRight: AppRadius.radiusS,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    3,
                    (_) => Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.skewX(-0.3),
                      child: Container(width: 10, color: colors.surface),
                    ),
                  ),
                ),
              ),
              // Play icon area
              Expanded(
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: colors.surface,
                  size: AppIconSizes.sm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  Text Section: Playful subtitle + Headline
  // ════════════════════════════════════════════════════════════════
  Widget _buildTextSection(ColorScheme colors) {
    return Column(
      children: [
        // Playful handwritten-style text
        Text(
          'Please add a video',
          style: context.textTheme.headlineMedium?.copyWith(
            color: colors.tertiary,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        ),

        gapH16,
        // Descriptive paragraph
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
          child: Text(
            'Paste a Youtube video link below to start learning',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  Input Section: URL Field + Gradient CTA Button
  // ════════════════════════════════════════════════════════════════
  Widget _buildInputSection(ColorScheme colors) {
    return Column(
      key: _inputSectionKey,
      children: [
        // ── URL Input ──
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.roundedL,
            boxShadow: [
              BoxShadow(
                color: colors.onSurface.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _urlController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'https://youtube-video-url.com/...',
              hintStyle: TextStyle(color: colors.outlineVariant),
              suffixIcon: IconButton(
                onPressed: _pasteFromClipboard,
                icon: Icon(Icons.content_paste_rounded, color: colors.outlineVariant),
                tooltip: 'Paste from clipboard',
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.roundedL,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.roundedL,
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p24,
                vertical: AppSizes.p20,
              ),
            ),
            style: TextStyle(color: colors.onSurface, fontSize: 16),
            onSubmitted: (_) => _submit(),
          ),
        ),

        gapH16,

        // ── CTA Button ──
        SizedBox(
          height: AppSizes.buttonHeightXl,
          width: double.infinity,
          child: AppPrimaryButton(
            onPressed: _submit,
            borderRadius: AppRadius.roundedL,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.dashboardAddToLibrary,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                gapW8,
                Icon(Icons.add_circle_rounded, color: colors.onPrimary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _scrollController.dispose();
    _urlController.dispose();
    _staggerController.dispose();
    _characterBounceController.dispose();
    _blobPulseController.dispose();
    super.dispose();
  }
}
