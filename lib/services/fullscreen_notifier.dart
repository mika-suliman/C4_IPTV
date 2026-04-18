import 'package:flutter/foundation.dart';

/// Shared notifier so C4LiveGridScreen can tell MainShellScreen
/// to hide the nav rail and header during fullscreen playback.
final fullscreenNotifier = ValueNotifier<bool>(false);
