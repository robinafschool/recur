import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_theme.dart';
import 'navigation/navigation.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE__PROJECT_URL'];
    final supabaseKey = dotenv.env['SUPABASE__API_KEY'];

    if (supabaseUrl == null || supabaseKey == null) {
      throw Exception('Missing Supabase configuration in .env file');
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    rethrow;
  }

  runApp(const ProviderScope(child: RecurApp()));
}

class RecurApp extends ConsumerWidget {
  const RecurApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authRepositoryProvider).currentSession;
    final initialRoute = session != null ? AppRoutes.home : AppRoutes.login;

    return MaterialApp(
      title: 'Recur',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.home: (context) =>
            const MainNavigationScreen(initialIndex: 1),
        AppRoutes.habits: (context) => const ScheduleScreen(),
        AppRoutes.journalList: (context) => const JournalListScreen(),
        AppRoutes.journalEntry: (context) => const JournalEntryScreen(),
        AppRoutes.schedule: (context) => const ScheduleScreen(),
        AppRoutes.analytics: (context) => const AnalyticsScreen(),
        AppRoutes.focus: (context) => const FocusScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
      },
    );
  }
}
