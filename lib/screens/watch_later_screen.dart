import 'package:another_iptv_player/l10n/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/watch_later_controller.dart';
import '../models/content_type.dart';
import '../models/playlist_content_model.dart';
import '../widgets/common/c4_content_rail.dart';

class WatchLaterScreen extends StatefulWidget {
  const WatchLaterScreen({super.key});

  @override
  State<WatchLaterScreen> createState() => _WatchLaterScreenState();
}

class _WatchLaterScreenState extends State<WatchLaterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchLaterController>().loadWatchLaterItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WatchLaterController>();
    final items = controller.watchLaterItems;

    final liveItems = items
        .where((i) => i.contentType == ContentType.liveStream)
        .map(_mapToContentItem)
        .toList();
    final movieItems = items
        .where((i) => i.contentType == ContentType.vod)
        .map(_mapToContentItem)
        .toList();
    final seriesItems = items
        .where((i) => i.contentType == ContentType.series)
        .map(_mapToContentItem)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent, // Parent provides background
      body: controller.isLoading && items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.only(top: 24, bottom: 64),
                  children: [
                    if (liveItems.isNotEmpty)
                      C4ContentRail(
                        title: context.loc.live_tv,
                        items: liveItems,
                        isPortrait: false,
                        onItemTap: (ctx, item) => _playItem(ctx, item),
                      ),
                    if (movieItems.isNotEmpty)
                      C4ContentRail(
                        title: context.loc.movies,
                        items: movieItems,
                        isPortrait: true,
                        onItemTap: (ctx, item) => _playItem(ctx, item),
                      ),
                    if (seriesItems.isNotEmpty)
                      C4ContentRail(
                        title: context.loc.series_plural,
                        items: seriesItems,
                        isPortrait: true,
                        onItemTap: (ctx, item) => _playItem(ctx, item),
                      ),
                  ],
                ),
    );
  }

  ContentItem _mapToContentItem(dynamic h) {
    return ContentItem(
      h.streamId,
      h.title,
      h.imagePath ?? '',
      h.contentType,
    );
  }

  void _playItem(BuildContext context, ContentItem item) {
    final controller = context.read<WatchLaterController>();
    final data = controller.watchLaterItems.firstWhere(
      (i) => i.streamId == item.id && i.contentType == item.contentType,
    );
    controller.playContent(context, data);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_rounded, size: 64, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            context.loc.watch_later_empty_message,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            context.loc.watch_later_empty_description,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
