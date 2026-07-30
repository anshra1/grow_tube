import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

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
      curve: const Interval(0, 0.4, curve: Curves.easeOut),
    );
    _illustrationSlideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: const Interval(0, 0.4, curve: Curves.easeOut),
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
      curve: const Interval(0.5, 1, curve: Curves.easeOut),
    );
    _inputSlideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: const Interval(0.5, 1, curve: Curves.easeOut),
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

  Future<void> _launchYouTube() async {
    final uri = Uri.parse('https://www.youtube.com/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    final scrollPhysics = keyboardInset > 0
        ? const NeverScrollableScrollPhysics()
        : const ClampingScrollPhysics();

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

              const Gap(16),

              // ── Text Section ──
              SlideTransition(
                position: _textSlideAnim,
                child: FadeTransition(
                  opacity: _textFadeAnim,
                  child: _buildTextSection(colors),
                ),
              ),

              const Gap(16),

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
  //  Illustration: Floating Video Card
  // ════════════════════════════════════════════════════════════════
  Widget _buildIllustrationSection(ColorScheme colors) {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── Pulsing background glow ──
          AnimatedBuilder(
            animation: _blobScaleAnim,
            builder: (context, child) {
              return Transform.scale(scale: _blobScaleAnim.value, child: child);
            },
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.12),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // ── Floating Video Card ──
          AnimatedBuilder(
            animation: _bounceAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceAnim.value),
                child: child,
              );
            },
            child: Container(
              width: 180,
              height: 120,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing Play Button
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: colors.onPrimary,
                      size: 36,
                    ),
                  ),
                  // Abstract UI line (Bottom left)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Abstract UI line (Bottom right)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      width: 24,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating Accent Elements ──
          Positioned(
            top: 40,
            left: 30,
            child: AnimatedBuilder(
              animation: _bounceAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_bounceAnim.value * 0.4),
                  child: child,
                );
              },
              child: Icon(
                Icons.menu_book_rounded,
                color: colors.secondary.withValues(alpha: 0.6),
                size: 28,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 25,
            child: AnimatedBuilder(
              animation: _bounceAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_bounceAnim.value * 0.6),
                  child: child,
                );
              },
              child: Icon(
                Icons.lightbulb_rounded,
                color: colors.tertiary.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  Text Section: Professional Headline + Subtitle
  // ════════════════════════════════════════════════════════════════
  Widget _buildTextSection(ColorScheme colors) {
    return Column(
      children: [
        Text(
          'Your Learning Journey Starts Here',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const Gap(12),
        Text(
          'Paste a YouTube link below to add a video and learn without distractions.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
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
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: _urlController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Paste YouTube link here...',
              hintStyle: TextStyle(
                color: colors.onSurfaceVariant.withValues(alpha: 0.85),
              ),
              suffixIcon: IconButton(
                onPressed: _pasteFromClipboard,
                icon: Icon(Icons.content_paste_rounded, color: colors.primary),
                tooltip: 'Paste from clipboard',
              ),
              border: const OutlineInputBorder(
                borderRadius: AppRadius.roundedL,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.roundedL,
                borderSide: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.7),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.roundedL,
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.roundedL,
                borderSide: BorderSide(color: colors.error, width: 1.4),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.roundedL,
                borderSide: BorderSide(color: colors.error, width: 2),
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p24,
                vertical: AppSizes.p20,
              ),
            ),
            style: TextStyle(color: colors.onSurface, fontSize: 16),
            onSubmitted: (_) => _submit(),
          ),
        ),

        const Gap(16),

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
              ],
            ),
          ),
        ),

        const Gap(16),

        // ── Open YouTube Launcher ──
        TextButton.icon(
          onPressed: _launchYouTube,
          icon: Icon(Icons.open_in_new_rounded, color: colors.primary, size: 20),
          label: Text(
            'Open YouTube App',
            style: context.textTheme.titleSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedM),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _scrollController.dispose();
    _urlController.dispose();
    _staggerController.dispose();
    _characterBounceController.dispose();
    _blobPulseController.dispose();
    super.dispose();
  }
}
