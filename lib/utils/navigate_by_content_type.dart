import 'package:another_iptv_player/screens/m3u/series/m3u_series_screen.dart';
import 'package:another_iptv_player/utils/get_playlist_type.dart';
import 'package:flutter/material.dart';
import 'package:another_iptv_player/models/content_type.dart';
import 'package:another_iptv_player/models/playlist_content_model.dart';
import '../screens/live_stream/live_stream_screen.dart';
import '../screens/m3u/m3u_player_screen.dart';
import '../screens/movies/movie_screen.dart';
import '../screens/series/series_screen.dart';
import '../screens/desktop/desktop_movie_detail_screen.dart';
import '../screens/desktop/desktop_series_detail_screen.dart';

bool _isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= 900;
}

void navigateByContentType(BuildContext context, ContentItem content) {
  if (isM3u &&
      ((content.m3uItem != null && content.m3uItem!.groupTitle == null) ||
          content.contentType == ContentType.series)) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => M3uPlayerScreen(
          contentItem: ContentItem(
            content.m3uItem!.id,
            content.m3uItem!.name ?? '',
            content.m3uItem!.tvgLogo ?? '',
            content.m3uItem!.contentType,
            m3uItem: content.m3uItem!,
          ),
        ),
      ),
    );

    return;
  }

  final desktop = _isDesktop(context);

  switch (content.contentType) {
    case ContentType.liveStream:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveStreamScreen(content: content),
        ),
      );
    case ContentType.vod:
      if (desktop && isXtreamCode) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DesktopMovieDetailScreen(contentItem: content),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieScreen(contentItem: content),
          ),
        );
      }
    case ContentType.series:
      if (isXtreamCode) {
        if (desktop) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DesktopSeriesDetailScreen(contentItem: content),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeriesScreen(contentItem: content),
            ),
          );
        }
      } else if (isM3u) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => M3uSeriesScreen(contentItem: content),
          ),
        );
      }
  }
}
