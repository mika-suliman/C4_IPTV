import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Map<String, dynamic>>> getTrendingMovies() async {
    if (AppConfig.tmdbApiKey == 'YOUR_TMDB_API_KEY_HERE' || AppConfig.tmdbApiKey.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending/movie/week?api_key=${AppConfig.tmdbApiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      }
    } catch (e) {
      print('TMDB Error: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getTrendingTv() async {
     if (AppConfig.tmdbApiKey == 'YOUR_TMDB_API_KEY_HERE' || AppConfig.tmdbApiKey.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending/tv/week?api_key=${AppConfig.tmdbApiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      }
    } catch (e) {
      print('TMDB Error: $e');
    }
    return [];
  }

  String getPosterUrl(String? path) {
    if (path == null) return '';
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  String getBackdropUrl(String? path) {
    if (path == null) return '';
    return 'https://image.tmdb.org/t/p/original$path';
  }
}
