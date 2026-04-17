import 'package:flutter/material.dart';
import '../../models/playlist_content_model.dart';
import '../../utils/navigate_by_content_type.dart';
import 'c4_card.dart';

class C4ContentRail extends StatelessWidget {
  final String title;
  final List<ContentItem> items;
  final bool isPortrait;

  const C4ContentRail({
    super.key,
    required this.title,
    required this.items,
    this.isPortrait = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cardWidth = isPortrait ? 160.0 : 280.0;
    final cardHeight = isPortrait ? 240.0 : 160.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: cardHeight + 40, // Extra space for focus scale
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: C4Card(
                    title: item.name,
                    imageUrl: item.imageUrl,
                    width: cardWidth,
                    height: cardHeight,
                    onTap: () => navigateByContentType(context, item),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
