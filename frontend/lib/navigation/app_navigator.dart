import 'package:flutter/material.dart';
import '../utils/route_generator.dart';

/// Navigation index constants for the bottom nav bar
class NavIndex {
  NavIndex._();

  static const int analytics = 0;
  static const int journalList = 1;
  static const int journalEntry = 2;
  static const int aiSchedule = 3;
  static const int settings = 4;
}

/// Route paths used throughout the app
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String analytics = '/analytics';
  static const String journalList = '/journal-list';
  static const String journalEntry = '/journal-entry';
  static const String aiSchedule = '/ai-schedule';
  static const String settings = '/settings';
  static const String habits = '/habits';
  static const String focus = '/focus';

  /// Ordered list of nav bar routes
  static const List<String> navRoutes = [
    analytics,
    journalList,
    journalEntry,
    aiSchedule,
    settings,
  ];
}

/// Centralized navigation helper for screen transitions
class AppNavigator {
  /// Navigate to a screen by nav index with slide transition
  /// Uses late-bound screen builder to avoid circular imports
  static void navigateToIndex(
    BuildContext context,
    int currentIndex,
    int targetIndex, {
    Widget Function(int index)? screenBuilder,
  }) {
    if (currentIndex == targetIndex) return;

    final direction = getSlideDirection(currentIndex, targetIndex);

    // If no screen builder provided, use route-based navigation
    if (screenBuilder == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.navRoutes[targetIndex]);
      return;
    }

    Navigator.pushReplacement(
      context,
      SlideRoute(
        page: screenBuilder(targetIndex),
        direction: direction,
      ),
    );
  }

  /// Get screen widget for index - implemented separately to avoid circular imports
  /// This should be called from main_navigation_screen or similar container
  static Widget Function(int)? screenBuilder;

  /// Register the screen builder (called from main.dart or similar)
  static void registerScreenBuilder(Widget Function(int) builder) {
    screenBuilder = builder;
  }
}
