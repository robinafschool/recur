import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/gradient_header.dart';
import '../utils/route_generator.dart';
import 'analytics_screen.dart';
import 'journal_entry_screen.dart';
import 'ai_schedule_screen.dart';
import 'settings_screen.dart';

class JournalListScreen extends StatefulWidget {
  final bool showNavBar;

  const JournalListScreen({super.key, this.showNavBar = true});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  static const int _currentIndex = 1; // Journal Entries is middle item

  void _navigateToScreen(int index) {
    if (index == _currentIndex)
      return; // Don't navigate if already on this screen

    final routes = [
      '/analytics',
      '/journal-list',
      '/journal-entry',
      '/ai-schedule',
      '/settings',
    ];
    final direction = getSlideDirection(_currentIndex, index);

    Navigator.pushReplacement(
      context,
      SlideRoute(page: _getRouteWidget(routes[index]), direction: direction),
    );
  }

  Widget _getRouteWidget(String route) {
    switch (route) {
      case '/analytics':
        return const AnalyticsScreen();
      case '/journal-list':
        return const JournalListScreen();
      case '/journal-entry':
        return const JournalEntryScreen();
      case '/ai-schedule':
        return const AiScheduleScreen();
      case '/settings':
        return const SettingsScreen();
      default:
        return const JournalListScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
            AppTheme.primaryLight.withOpacity(0.5),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GradientHeader(
                icon: Icons.book_outlined,
                title: 'Journal Entries',
                description:
                    'Review your past entries and track your progress over time.',
              ),
              const SizedBox(height: AppTheme.spacing30),
              _buildEntriesList(),
            ],
          ),
        ),
      ),
    );

    if (!widget.showNavBar) {
      return body;
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _navigateToScreen,
      ),
    );
  }

  Widget _buildEntriesList() {
    final entries = [
      JournalEntry(
        date: 'Today, Dec 15',
        time: '2:30 PM',
        preview:
            'Had a great morning workout session. Feeling energized and ready to tackle the day. Need to focus on completing the project proposal...',
        tags: ['Exercise', 'Work'],
      ),
      JournalEntry(
        date: 'Yesterday, Dec 14',
        time: '8:15 PM',
        preview:
            'Reflected on the week\'s progress. Made good strides with my reading habit, but need to improve consistency with meditation...',
        tags: ['Reflection', 'Habits'],
      ),
      JournalEntry(
        date: 'Dec 13',
        time: '6:45 PM',
        preview:
            'Completed the morning routine successfully. Feeling more organized and in control of my schedule...',
        tags: ['Routine'],
      ),
      JournalEntry(
        date: 'Dec 12',
        time: '9:20 AM',
        preview:
            'Started the day with meditation and journaling. Set new goals for the month ahead...',
        tags: ['Goals', 'Meditation'],
      ),
    ];

    return Column(
      children: entries.map((entry) => _buildEntryItem(entry)).toList(),
    );
  }

  Widget _buildEntryItem(JournalEntry entry) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/journal-entry'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing15),
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.date, style: AppTheme.bodySecondary),
                Text(
                  entry.time,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing10),
            Text(
              entry.preview,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spacing10),
            Wrap(
              spacing: AppTheme.spacing8,
              runSpacing: AppTheme.spacing8,
              children: entry.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing12,
                        vertical: AppTheme.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusCircular,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class JournalEntry {
  final String date;
  final String time;
  final String preview;
  final List<String> tags;

  JournalEntry({
    required this.date,
    required this.time,
    required this.preview,
    required this.tags,
  });
}
