import 'package:another_iptv_player/database/database.dart';
import 'package:another_iptv_player/models/content_type.dart';
import 'package:another_iptv_player/models/playlist_content_model.dart';
import 'package:another_iptv_player/repositories/watch_later_repository.dart';
import 'package:another_iptv_player/services/app_state.dart';
import 'package:another_iptv_player/services/service_locator.dart';
import 'package:another_iptv_player/utils/get_playlist_type.dart';
import 'package:another_iptv_player/utils/navigate_by_content_type.dart';
import 'package:another_iptv_player/screens/m3u/m3u_player_screen.dart';
import 'package:another_iptv_player/screens/series/episode_screen.dart';
import 'package:flutter/material.dart';

class WatchLaterController extends ChangeNotifier {
  final WatchLaterRepository _repository = WatchLaterRepository();
  final _database = getIt<AppDatabase>();

  List<WatchLaterData> _watchLaterItems = [];
  bool _isLoading = false;
  String? _error;

  List<WatchLaterData> get watchLaterItems => _watchLaterItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WatchLaterController();

  Future<void> loadWatchLaterItems() async {
    try {
      _setLoading(true);
      _setError(null);

      _watchLaterItems = await _repository.getAllWatchLaterItems();
      notifyListeners();
    } catch (e) {
      _setError('Error loading watch later items: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addToWatchLater(ContentItem contentItem) async {
    try {
      _setError(null);
      await _repository.addWatchLater(contentItem);
      await loadWatchLaterItems();
      return true;
    } catch (e) {
      _setError('Error adding to watch later: $e');
      return false;
    }
  }

  Future<bool> removeFromWatchLater(String streamId, ContentType contentType) async {
    try {
      _setError(null);
      await _repository.removeWatchLater(streamId, contentType);
      await loadWatchLaterItems();
      return true;
    } catch (e) {
      _setError('Error removing from watch later: $e');
      return false;
    }
  }

  Future<bool> toggleWatchLater(ContentItem contentItem) async {
    try {
      _setError(null);
      final result = await _repository.toggleWatchLater(contentItem);
      await loadWatchLaterItems();
      return result;
    } catch (e) {
      _setError('Error toggling watch later: $e');
      return false;
    }
  }

  Future<bool> isWatchLater(String streamId, ContentType contentType) async {
    return await _repository.isWatchLater(streamId, contentType);
  }

  Future<void> playContent(BuildContext context, WatchLaterData item) async {
    try {
      _setError(null);
      switch (item.contentType) {
        case ContentType.liveStream:
          await _playLiveStream(context, item);
          break;
        case ContentType.vod:
          await _playMovie(context, item);
          break;
        case ContentType.series:
          await _playSeries(context, item);
          break;
      }
    } catch (e) {
      _setError('Video oynatılırken hata oluştu: $e');
    }
  }

  Future<void> _playLiveStream(BuildContext context, WatchLaterData item) async {
    if (isXtreamCode) {
      final liveStream = await _database.findLiveStreamById(
        item.streamId,
        AppState.currentPlaylist!.id,
      );

      navigateByContentType(
        context,
        ContentItem(
          item.streamId,
          item.title,
          item.imagePath ?? '',
          item.contentType,
          liveStream: liveStream,
        ),
      );
    } else if (isM3u) {
      final liveStream = await _database.getM3uItemsByIdAndPlaylist(
        AppState.currentPlaylist!.id,
        item.streamId,
      );

      navigateByContentType(
        context,
        ContentItem(
          liveStream!.url,
          item.title,
          item.imagePath ?? '',
          item.contentType,
          m3uItem: liveStream,
        ),
      );
    }
  }

  Future<void> _playMovie(BuildContext context, WatchLaterData item) async {
    if (isXtreamCode) {
      final movie = await _database.findMovieById(
        item.streamId,
        AppState.currentPlaylist!.id,
      );

      navigateByContentType(
        context,
        ContentItem(
          item.streamId,
          item.title,
          item.imagePath ?? '',
          item.contentType,
          containerExtension: movie?.containerExtension,
          vodStream: movie,
        ),
      );
    } else if (isM3u) {
      var movie = await _database.getM3uItemsByIdAndPlaylist(
        AppState.currentPlaylist!.id,
        item.streamId,
      );

      navigateByContentType(
        context,
        ContentItem(
          movie!.url,
          item.title,
          item.imagePath ?? '',
          item.contentType,
          m3uItem: movie,
        ),
      );
    }
  }

  Future<void> _playSeries(BuildContext context, WatchLaterData item) async {
    if (isXtreamCode) {
      final series = await _database.findSeriesById(
        item.streamId,
        AppState.currentPlaylist!.id,
      );

      final seriesResponse = await AppState.xtreamCodeRepository!.getSeriesInfo(
        series!.seriesId,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EpisodeScreen(
            seriesInfo: seriesResponse!.seriesInfo,
            seasons: seriesResponse.seasons,
            episodes: seriesResponse.episodes,
            contentItem: ContentItem(
              series.seriesId.toString(),
              item.title,
              item.imagePath ?? "",
              ContentType.series,
              seriesStream: series,
            ),
          ),
        ),
      );
    } else if (isM3u) {
      var m3uItem = await _database.getM3uItemsByIdAndPlaylist(
        AppState.currentPlaylist!.id,
        item.streamId,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => M3uPlayerScreen(
            contentItem: ContentItem(
              m3uItem!.id,
              m3uItem.name ?? '',
              m3uItem.tvgLogo ?? '',
              m3uItem.contentType,
              m3uItem: m3uItem,
            ),
          ),
        ),
      );
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
