import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/constants/app_links.dart';
import 'package:levelup_tube/src/core/widgets/atoms/top_header.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/settings/pages/setting_page_widgets/setting_card.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  static final Uri _privacyPolicyUri = Uri.parse(AppLinks.privacyPolicy);
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'Version ${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  Future<void> _handlePrivacyTap() async {
    final launched = await launchUrl(
      _privacyPolicyUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: const Text('Could not open Privacy Policy'),
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const TopHeaderText('About')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SettingsCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: _handlePrivacyTap,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Open Source Licenses'),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'LevelUp Tube',
                        applicationVersion: _version,
                      );
                    },
                  ),
                 
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Version'),
                    trailing: _version.isEmpty
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_version),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
