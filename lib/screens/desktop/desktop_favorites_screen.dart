import 'package:another_iptv_player/l10n/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:another_iptv_player/controllers/favorites_controller.dart';
import 'package:another_iptv_player/models/content_type.dart';
import 'package:another_iptv_player/models/playlist_content_model.dart';
import 'package:another_iptv_player/widgets/common/c4_content_rail.dart';
import 'package:provider/provider.dart';

class DesktopFavoritesScreen extends StatefulWidget {
  const DesktopFavoritesScreen({super.key});

  @override
  State<DesktopFavoritesScreen> createState() => _DesktopFavoritesScreenState();
}

class _DesktopFavoritesScreenState extends State<DesktopFavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesController>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FavoritesController>();
    final favorites = controller.favorites;

    final liveFavs = favorites
        .where((f) => f.contentType == ContentType.liveStream)
        .map((f) => ContentItem(f.streamId, f.name, f.imagePath ?? '', f.contentType))
        .toList();
    final movieFavs = favorites
        .where((f) => f.contentType == ContentType.vod)
        .map((f) => ContentItem(f.streamId, f.name, f.imagePath ?? '', f.contentType))
        .toList();
    final seriesFavs = favorites
        .where((f) => f.contentType == ContentType.series)
        .map((f) => ContentItem(f.streamId, f.name, f.imagePath ?? '', f.contentType))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: controller.isLoading && favorites.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.only(top: 24, bottom: 64),
                  children: [
                    if (liveFavs.isNotEmpty)
                      C4ContentRail(
                        title: '${context.loc.live_tv} (${liveFavs.length})',
                        items: liveFavs,
                        isPortrait: false,
                        onItemTap: (ctx, item) => _playFavorite(ctx, item),
                      ),
                    if (movieFavs.isNotEmpty)
                      C4ContentRail(
                        title: '${context.loc.movies} (${movieFavs.length})',
                        items: movieFavs,
                        isPortrait: true,
                        onItemTap: (ctx, item) => _playFavorite(ctx, item),
                      ),
                    if (seriesFavs.isNotEmpty)
                      C4ContentRail(
                        title: '${context.loc.series_plural} (${seriesFavs.length})',
                        items: seriesFavs,
                        isPortrait: true,
                        onItemTap: (ctx, item) => _playFavorite(ctx, item),
                      ),
                  ],
                ),
    );
  }

  void _playFavorite(BuildContext context, ContentItem item) {
    final controller = context.read<FavoritesController>();
    final fav = controller.favorites.firstWhere(
      (f) => f.streamId == item.id && f.contentType == item.contentType,
    );
    controller.playFavorite(context, fav);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_rounded, size: 64, color: Colors.red.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            context.loc.no_favorites_found,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mark channels, movies or series as favorites to see them here.',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
