import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'navigation/navigation.dart';
import 'screens/screens.dart';

void main() {
  runApp(const RecurApp());
}

class RecurApp extends StatelessWidget {
  const RecurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recur',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const MainNavigationScreen(initialIndex: 1),
        AppRoutes.habits: (context) => const HabitsScreen(),
        AppRoutes.journalList: (context) => const JournalListScreen(),
        AppRoutes.journalEntry: (context) => const JournalEntryScreen(),
        AppRoutes.aiSchedule: (context) => const AiScheduleScreen(),
        AppRoutes.analytics: (context) => const AnalyticsScreen(),
        AppRoutes.focus: (context) => const FocusScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
      },
    );
  }
}
