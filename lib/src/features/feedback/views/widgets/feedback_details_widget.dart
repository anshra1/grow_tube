import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:levelup_tube/src/features/feedback/models/feedback_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    required this.feedback,
    required this.dateStr,
    this.isExpanded = false,
    this.onTap,
    super.key,
  });

  final FeedbackModel feedback;
  final String dateStr;
  final bool isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      feedback.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (feedback.attachmentUrls != null &&
                          feedback.attachmentUrls!.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.attachment, size: 16, color: Colors.grey),
                        ),
                      Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.topCenter,
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: isExpanded ? null : 3,
                      overflow: isExpanded ? null : TextOverflow.ellipsis,
                    ),
                    if (isExpanded &&
                        feedback.email != null &&
                        feedback.email!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 4),
                      Text(
                        'Email: ${feedback.email}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                    if (isExpanded &&
                        feedback.attachmentUrls != null &&
                        feedback.attachmentUrls!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 4),
                      Text(
                        'Attachments:',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: feedback.attachmentUrls!.map((url) {
                          final isAudio =
                              url.toLowerCase().contains('.mp3') ||
                              url.toLowerCase().contains('.wav') ||
                              url.toLowerCase().contains('.m4a') ||
                              url.toLowerCase().contains('.aac') ||
                              url.toLowerCase().contains('audio');
                          if (isAudio) {
                            return ActionChip(
                              avatar: const Icon(Icons.audiotrack, size: 16),
                              label: const Text('Play Audio'),
                              onPressed: () async {
                                final uri = Uri.parse(url);
                                try {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } on Exception catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Could not play audio link.'),
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          } else {
                            return GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse(url);
                                try {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } on Exception catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Could not open image link.'),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            );
                          }
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
