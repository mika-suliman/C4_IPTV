import 'package:flutter/material.dart';
import 'package:another_iptv_player/database/database.dart';
import 'package:another_iptv_player/models/content_type.dart';
import 'package:another_iptv_player/models/playlist_content_model.dart';
import 'package:another_iptv_player/repositories/watch_later_repository.dart';

class WatchLaterController extends ChangeNotifier {
  final WatchLaterRepository _repository = WatchLaterRepository();

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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
