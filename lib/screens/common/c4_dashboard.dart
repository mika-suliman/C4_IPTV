import '../../utils/navigate_by_content_type.dart';
import '../../models/playlist_content_model.dart';
import '../../services/tmdb_service.dart';
import '../../controllers/watch_later_controller.dart';
import '../../widgets/common/c4_dashboard_hero.dart';
import '../../widgets/common/c4_content_rail.dart';

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

      await Future.wait([
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

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 1. Hero Section
        if (xtreamController.heroItem != null)
          C4DashboardHero(item: xtreamController.heroItem!),

        const SizedBox(height: 24),

        // 2. Trending this week (TMDB)
        if (_trendingItems.isNotEmpty)
          C4ContentRail(
            title: 'Trending this week',
            items: _trendingItems,
          ),

        // 3. Recommendations (Local random)
        if (xtreamController.recommendations.isNotEmpty)
          C4ContentRail(
            title: 'Recommended for you',
            items: xtreamController.recommendations,
          ),

        // 4. Continue watching (VOD/Series)
        if (historyController.continueWatching.isNotEmpty)
          C4ContentRail(
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
          ),

        // 5. Watch later
        if (watchLaterController.watchLaterItems.isNotEmpty)
          C4ContentRail(
            title: 'Watch later',
            items: watchLaterController.watchLaterItems
                .map((h) => ContentItem(
                      h.streamId,
                      h.title,
                      h.imagePath ?? '',
                      h.contentType,
                    ))
                .toList(),
          ),

        // 6. Recent channels (Live TV)
        if (historyController.liveHistory.isNotEmpty)
          C4ContentRail(
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
          ),

        // 7. Favorites (Live TV)
        if (favoritesController.favorites.isNotEmpty)
          C4ContentRail(
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
          ),

        const SizedBox(height: 48),
      ],
    );
  }
}
