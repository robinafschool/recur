import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  void _navigateToScreen(int index) {
    final routes = ['/journal-list', '/journal-entry', '/ai-schedule'];
    if (index != 0) {
      // Don't navigate if already on journal list
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppTheme.spacing30),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/analytics'),
                      child: const Text('graph'),
                    ),
                    const SizedBox(height: AppTheme.spacing20),
                    Expanded(child: _buildEntriesList()),
                  ],
                ),
              ),
            ),
            BottomNavBar(
              currentIndex: 0,
              onTap: _navigateToScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Journal Entries',
          style: AppTheme.heading1,
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/settings'),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor,
                width: AppTheme.borderWidthMedium,
              ),
            ),
            child: const Center(
              child: Text(
                'stgs',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: AppTheme.fontSizeSmall,
                ),
              ),
            ),
          ),
        ),
      ],
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

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) => _buildEntryItem(entries[index]),
    );
  }

  Widget _buildEntryItem(JournalEntry entry) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/journal-entry'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing15),
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.borderColor,
            width: AppTheme.borderWidthMedium,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.date,
                  style: AppTheme.bodySecondary,
                ),
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
                fontSize: AppTheme.fontSizeLarge,
                color: Color(0xFFCCCCCC),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spacing10),
            Wrap(
              spacing: AppTheme.spacing10,
              children: entry.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing8,
                          vertical: AppTheme.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSmall),
                          border: Border.all(
                            color: const Color(0xFF444444),
                            width: AppTheme.borderWidthThin,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: AppTheme.caption,
                        ),
                      ))
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

