import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/xtream_code_home_controller.dart';
import '../../controllers/watch_history_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/watch_later_controller.dart';
import '../../l10n/localization_extension.dart';
import '../../models/content_type.dart';
import '../../models/playlist_content_model.dart';
import '../../services/tmdb_service.dart';
import '../../widgets/common/c4_dashboard_hero.dart';
import '../../widgets/common/c4_content_rail.dart';
import '../../services/service_locator.dart';
import '../../database/database.dart';
import '../../services/app_state.dart';
import '../../utils/navigate_by_content_type.dart';

class C4Dashboard extends StatefulWidget {
  final String playlistId;

  const C4Dashboard({super.key, required this.playlistId});

  @override
  State<C4Dashboard> createState() => _C4DashboardState();
}

class _C4DashboardState extends State<C4Dashboard> {
  final TmdbService _tmdbService = TmdbService();
  List<ContentItem> _trendingItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final trendingMovies = await _tmdbService.getTrendingMovies();
    final trendingTv = await _tmdbService.getTrendingTv();

    if (mounted) {
      setState(() {
        _trendingItems = [
          ...trendingMovies.map((m) => ContentItem(
                m['id'].toString(),
                m['title'] ?? m['name'] ?? '',
                _tmdbService.getPosterUrl(m['poster_path']),
                ContentType.vod,
              )),
          ...trendingTv.map((m) => ContentItem(
                m['id'].toString(),
                m['name'] ?? m['title'] ?? '',
                _tmdbService.getPosterUrl(m['poster_path']),
                ContentType.series,
              )),
        ];
        _trendingItems.shuffle();
      });
    }

    if (mounted) {
      final historyController = context.read<WatchHistoryController>();
      final favoritesController = context.read<FavoritesController>();
      final watchLaterController = context.read<WatchLaterController>();

      await Future.wait<void>([
        historyController.loadWatchHistory(),
        favoritesController.loadFavorites(),
        watchLaterController.loadWatchLaterItems(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final xtreamController = context.watch<XtreamCodeHomeController>();
    final historyController = context.watch<WatchHistoryController>();
    final favoritesController = context.watch<FavoritesController>();
    final watchLaterController = context.watch<WatchLaterController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width < 900 ? 24.0 : 48.0;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // 1. Hero Section
            if (xtreamController.heroItem != null)
              C4DashboardHero(item: xtreamController.heroItem!),

            const SizedBox(height: 32),

            // 2. Continue watching (VOD/Series) - Moved up for C4-TV feel
            if (historyController.continueWatching.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: C4ContentRail(
                  title: context.loc.continue_watching,
                  items: historyController.continueWatching
                      .where((h) => h.contentType != ContentType.liveStream)
                      .map((h) => ContentItem(
                            h.streamId,
                            h.title,
                            h.imagePath ?? '',
                            h.contentType,
                          ))
                      .toList(),
                  onItemTap: (ctx, item) {
                    final h = historyController.continueWatching.firstWhere(
                      (wh) =>
                          wh.streamId == item.id &&
                          wh.contentType == item.contentType,
                      orElse: () =>
                          throw Exception('WatchHistory not found for item'),
                    );
                    historyController.playContent(ctx, h);
                  },
                ),
              ),

            // 3. Trending this week (TMDB)
            if (_trendingItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: C4ContentRail(
                  title: 'Trending this week',
                  items: _trendingItems,
                  onItemTap: (ctx, item) => _playTmdbItem(ctx, item),
                ),
              ),

            // 4. Recommendations (Local random)
            if (xtreamController.recommendations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: C4ContentRail(
                  title: 'Recommended for you',
                  items: xtreamController.recommendations,
                ),
              ),

            // 5. Watch later
            if (watchLaterController.watchLaterItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: C4ContentRail(
                  title: 'Watch later',
                  items: watchLaterController.watchLaterItems
                      .map((h) => ContentItem(
                            h.streamId,
                            h.title,
                            h.imagePath ?? '',
                            h.contentType,
                          ))
                      .toList(),
                  onItemTap: (ctx, item) {
                    // Assuming watch later can be played using a similar logic
                    // or just standard navigation if it's already full.
                    navigateByContentType(ctx, item);
                  },
                ),
              ),

            // 6. Recent channels (Live TV)
            if (historyController.liveHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: C4ContentRail(
                  title: 'Recently watched channels',
                  items: historyController.liveHistory
                      .map((h) => ContentItem(
                            h.streamId,
                            h.title,
                            h.imagePath ?? '',
                            h.contentType,
                          ))
                      .toList(),
                  isPortrait: false,
                  onItemTap: (ctx, item) {
                    final h = historyController.liveHistory.firstWhere(
                      (wh) =>
                          wh.streamId == item.id &&
                          wh.contentType == item.contentType,
                      orElse: () =>
                          throw Exception('WatchHistory not found for item'),
                    );
                    historyController.playContent(ctx, h);
                  },
                ),
              ),

            // 7. Favorites (Live TV)
            if (favoritesController.favorites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: C4ContentRail(
                  title: 'Favorite channels',
                  items: favoritesController.favorites
                      .where((f) => f.contentType == ContentType.liveStream)
                      .map((f) => ContentItem(
                            f.streamId,
                            f.name,
                            f.imagePath ?? '',
                            f.contentType,
                          ))
                      .toList(),
                  isPortrait: false,
                  onItemTap: (ctx, item) {
                    final fav = favoritesController.favorites.firstWhere(
                      (f) =>
                          f.streamId == item.id &&
                          f.contentType == item.contentType,
                      orElse: () => throw Exception('Favorite not found for item'),
                    );
                    favoritesController.playFavorite(ctx, fav);
                  },
                ),
              ),

            const SizedBox(height: 64),
          ],
        );
      },
    );
  }

  Future<void> _playTmdbItem(BuildContext context, ContentItem item) async {
    final db = getIt<AppDatabase>();
    final playlistId = AppState.currentPlaylist?.id;

    if (playlistId == null) return;

    ContentItem? mapped;

    try {
      if (item.contentType == ContentType.vod) {
        final movies = await db.searchMovie(playlistId, item.name);
        if (movies.isNotEmpty) {
          // Look for exact match first
          final exact = movies.firstWhere(
            (m) => m.name.toLowerCase() == item.name.toLowerCase(),
            orElse: () => movies.first,
          );
          mapped = ContentItem(
            exact.streamId,
            exact.name,
            exact.streamIcon,
            ContentType.vod,
            containerExtension: exact.containerExtension,
            vodStream: exact,
          );
        }
      } else if (item.contentType == ContentType.series) {
        final series = await db.searchSeries(playlistId, item.name);
        if (series.isNotEmpty) {
          final exact = series.firstWhere(
            (s) => s.name.toLowerCase() == item.name.toLowerCase(),
            orElse: () => series.first,
          );
          mapped = ContentItem(
            exact.seriesId,
            exact.name,
            exact.cover ?? '',
            ContentType.series,
            seriesStream: exact,
          );
        }
      }

      if (mounted) {
        if (mapped != null) {
          navigateByContentType(context, mapped);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This title is not available in your playlist'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error matching content: $e')),
        );
      }
    }
  }
}
