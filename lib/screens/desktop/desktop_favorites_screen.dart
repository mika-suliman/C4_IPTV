import 'package:another_iptv_player/l10n/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:another_iptv_player/controllers/favorites_controller.dart';
import 'package:another_iptv_player/models/content_type.dart';
import 'package:another_iptv_player/models/favorite.dart';
import 'package:another_iptv_player/models/playlist_content_model.dart';
import 'package:another_iptv_player/utils/navigate_by_content_type.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Desktop favorites screen with tabs for Live TV / Movies / Series.
class DesktopFavoritesScreen extends StatefulWidget {
  const DesktopFavoritesScreen({super.key});

  @override
  State<DesktopFavoritesScreen> createState() => _DesktopFavoritesScreenState();
}

class _DesktopFavoritesScreenState extends State<DesktopFavoritesScreen>
    with SingleTickerProviderStateMixin {
  late FavoritesController _controller;
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = FavoritesController();
    _tabController = TabController(length: 3, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    await _controller.loadFavorites();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _removeFavorite(Favorite fav) async {
    final content = ContentItem(
      fav.streamId,
      fav.name,
      fav.imagePath ?? '',
      fav.contentType,
    );
    await _controller.toggleFavorite(content);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.removed_from_favorites),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded,
                        color: Colors.red, size: 26),
                    const SizedBox(width: 12),
                    Text(
                      context.loc.favorites,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_controller.favorites.length} items',
                      style: const TextStyle(
                          color: Color(0xFF747B8B), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: const Color(0xFF5A45FF),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF747B8B),
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(
                        text:
                            'Live TV (${_controller.liveStreamFavorites.length})'),
                    Tab(
                        text:
                            'Movies (${_controller.movieFavorites.length})'),
                    Tab(
                        text:
                            'Series (${_controller.seriesFavorites.length})'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E2128)),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF5A45FF)))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGrid(_controller.liveStreamFavorites,
                          ContentType.liveStream),
                      _buildGrid(
                          _controller.movieFavorites, ContentType.vod),
                      _buildGrid(
                          _controller.seriesFavorites, ContentType.series),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Favorite> items, ContentType type) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1D24),
              ),
              child: Icon(_typeIcon(type),
                  color: const Color(0xFF747B8B), size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_typeName(type)} favorites yet',
              style: const TextStyle(color: Color(0xFF747B8B), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: type == ContentType.liveStream ? 220 : 180,
        childAspectRatio: type == ContentType.liveStream ? 1.2 : 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final fav = items[index];
        return _FavoriteCard(
          favorite: fav,
          onTap: () {
            navigateByContentType(
              context,
              ContentItem(
                fav.streamId,
                fav.name,
                fav.imagePath ?? '',
                fav.contentType,
              ),
            );
          },
          onRemove: () => _removeFavorite(fav),
        );
      },
    );
  }

  IconData _typeIcon(ContentType t) {
    switch (t) {
      case ContentType.liveStream:
        return Icons.live_tv_rounded;
      case ContentType.vod:
        return Icons.movie_rounded;
      case ContentType.series:
        return Icons.tv_rounded;
    }
  }

  String _typeName(ContentType t) {
    switch (t) {
      case ContentType.liveStream:
        return 'Live TV';
      case ContentType.vod:
        return 'Movie';
      case ContentType.series:
        return 'Series';
    }
  }
}

class _FavoriteCard extends StatefulWidget {
  final Favorite favorite;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.favorite,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<_FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<_FavoriteCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13161C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E2128)),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color:
                            const Color(0xFF5A45FF).withValues(alpha: 0.15),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: widget.favorite.imagePath != null &&
                              widget.favorite.imagePath!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.favorite.imagePath!,
                              fit: widget.favorite.contentType ==
                                      ContentType.liveStream
                                  ? BoxFit.contain
                                  : BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  _buildFallback(),
                            )
                          : _buildFallback(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        widget.favorite.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Remove button on hover
                if (_hovered)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: widget.onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFF0F1115),
      child: Center(
        child: Icon(
          widget.favorite.contentType == ContentType.liveStream
              ? Icons.live_tv_rounded
              : widget.favorite.contentType == ContentType.vod
                  ? Icons.movie_rounded
                  : Icons.tv_rounded,
          size: 28,
          color: const Color(0xFF262A35),
        ),
      ),
    );
  }
}
