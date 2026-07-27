import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({required this.isHardUpdate, required this.storeUrl, super.key});

  final bool isHardUpdate;
  final String storeUrl;

  Future<void> _launchUrl() async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIllustration(),
            const SizedBox(height: 24),
            const Text(
              'Update Required',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              isHardUpdate
                  ? 'Please update our app for an improved experience! This version is no longer supported.'
                  : 'A new version of LevelUp Tube is available. Would you like to update now?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _launchUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F), // Red button
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Upgrade Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (!isHardUpdate) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                  child: const Text('Later'),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isHardUpdate) {
      return PopScope(canPop: false, child: dialog);
    }

    return dialog;
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
          ),
          // Tilted phone mockup
          Positioned(
            bottom: 12,
            child: Transform.rotate(
              angle: -0.15, // slight left tilt
              child: Container(
                width: 70,
                height: 105,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Phone top bezel (dark gray)
                    Container(
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF333333),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                    ),
                    // Red header
                    Container(
                      height: 24,
                      color: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 4,
                            width: 24,
                            color: Colors.white.withValues(alpha: .8),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 4,
                            width: 44,
                            color: Colors.white.withValues(alpha: .8),
                          ),
                        ],
                      ),
                    ),
                    // App content lines
                    const SizedBox(height: 12),
                    Container(height: 4, width: 50, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Container(height: 4, width: 35, color: Colors.grey.shade300),
                    const Spacer(),
                    // Bottom red bar/button inside app
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          height: 6,
                          width: 14,
                          color: const Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Green 'NEW' badge with white border
          Positioned(
            right: 0,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
