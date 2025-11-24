import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../models/models.dart';

class JournalListScreen extends StatefulWidget {
  final bool showNavBar;

  const JournalListScreen({super.key, this.showNavBar = true});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  void _navigateToScreen(int index) {
    AppNavigator.navigateToIndex(context, NavIndex.journalList, index);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: widget.showNavBar
          ? BottomNavBar(
              currentIndex: NavIndex.journalList,
              onTap: _navigateToScreen,
            )
          : null,
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
      onTap: () => Navigator.pushNamed(context, AppRoutes.journalEntry),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing15),
        child: AppCard(
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
                children: entry.tags.map((tag) => TagChip(label: tag)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
