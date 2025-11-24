import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/journal_list_screen.dart';
import 'screens/journal_entry_screen.dart';
import 'screens/ai_schedule_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/settings_screen.dart';

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/habits': (context) => const HabitsScreen(),
        '/journal-list': (context) => const JournalListScreen(),
        '/journal-entry': (context) => const JournalEntryScreen(),
        '/ai-schedule': (context) => const AiScheduleScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/focus': (context) => const FocusScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
