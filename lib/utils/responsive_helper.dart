import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double getCardWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1800) {
      return 200;
    } else if (screenWidth >= 1500) {
      return 180;
    } else if (screenWidth >= 1200) {
      return 160;
    } else if (screenWidth >= 600) {
      return 130;
    } else {
      return 110;
    }
  }

  static double getCardHeight(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1800) {
      return 280;
    } else if (screenWidth >= 1500) {
      return 260;
    } else if (screenWidth >= 1200) {
      return 220;
    } else if (screenWidth >= 600) {
      return 190;
    } else {
      return 160;
    }
  }

  static int getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1800) {
      return 8;
    } else if (screenWidth >= 1500) {
      return 7;
    } else if (screenWidth >= 1200) {
      return 6;
    } else if (screenWidth >= 900) {
      return 5;
    } else if (screenWidth >= 600) {
      return 4;
    } else if (screenWidth >= 400) {
      return 3;
    } else {
      return 2;
    }
  }

  static bool isDesktopOrTV(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= 900;
  }

  /// Max width for content grids (categories, search results)
  static double getMaxContentWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1800) {
      return 1600;
    } else if (screenWidth >= 1200) {
      return 1200;
    }
    return double.infinity;
  }

  /// Max width for settings and list screens
  static double getSettingsMaxWidth(BuildContext context) {
    if (isDesktopOrTV(context)) {
      return 700;
    }
    return double.infinity;
  }

  /// Max width for form screens (new playlist forms)
  static double getFormMaxWidth(BuildContext context) {
    if (isDesktopOrTV(context)) {
      return 600;
    }
    return double.infinity;
  }

  /// Helper widget that wraps content in Center + ConstrainedBox for desktop
  static Widget constrainedContent({
    required Widget child,
    required double maxWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
