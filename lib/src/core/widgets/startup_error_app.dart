import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/design_system/app_theme.dart';

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    required this.title,
    required this.message,
    this.debugDetails,
    super.key,
  });

  final String title;
  final String message;
  final String? debugDetails;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LevelUp Tube',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (kDebugMode && debugDetails != null) ...[
                          const SizedBox(height: 16),
                          SelectableText(
                            debugDetails!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
