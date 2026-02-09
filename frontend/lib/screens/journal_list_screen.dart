import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../models/journal_entry_record.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../view_models/journal_list_view_model.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key, this.showNavBar = true});

  final bool showNavBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDreams = ref.watch(journalListProvider);

    return GradientScaffold(
      bottomNavigationBar: showNavBar
          ? BottomNavBar(
              currentIndex: NavIndex.journalList,
              onTap: (index) => AppNavigator.navigateToIndex(context, NavIndex.journalList, index),
            )
          : null,
      child: RefreshIndicator(
        onRefresh: () => ref.read(journalListProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: AppTheme.spacing20,
            bottom: AppTheme.spacing20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
                child: GradientHeader(
                  icon: Icons.book_outlined,
                  title: 'Dream Journal',
                  description:
                      'Review your dreams and track patterns over time.',
                ),
              ),
              const SizedBox(height: AppTheme.spacing30),
              asyncDreams.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text('Error loading dreams: $err', style: AppTheme.bodySecondary),
                ),
                data: (dreams) => _DreamsList(dreams: dreams),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DreamsList extends StatefulWidget {
  const _DreamsList({required this.dreams});

  final List<JournalEntryRecord> dreams;

  static Map<String, List<JournalEntryRecord>> _groupDreamsByDate(List<JournalEntryRecord> dreams) {
    final grouped = <String, List<JournalEntryRecord>>{};
    for (final dream in dreams) {
      grouped.putIfAbsent(dream.date, () => []).add(dream);
    }
    return grouped;
  }

  @override
  State<_DreamsList> createState() => _DreamsListState();
}

class _DreamsListState extends State<_DreamsList> {
  PageController? _pageController;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _DreamsList._groupDreamsByDate(widget.dreams);
    if (grouped.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing60),
        child: Column(
          children: [
            Icon(Icons.nightlight_round, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: AppTheme.spacing20),
            Text('No dreams recorded yet', style: AppTheme.bodySecondary),
            const SizedBox(height: AppTheme.spacing10),
            Text(
              'Start recording your dreams to track patterns and improve lucid dreaming',
              style: AppTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    final dates = grouped.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    if (_pageController == null) {
      _pageController = PageController(initialPage: dates.length - 1);
    }
    final viewportHeight = MediaQuery.of(context).size.height;
    final boardHeight = viewportHeight * 1.2;
    return SizedBox(
      height: boardHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: dates.length,
        itemBuilder: (context, i) => Center(
          child: _DayColumn(
            date: dates[i],
            dreams: grouped[dates[i]]!,
          ),
        ),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({required this.date, required this.dreams});

  final String date;
  final List<JournalEntryRecord> dreams;

  static const double _columnWidth = 320;

  static String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final entryDate = DateTime(date.year, date.month, date.day);
      if (entryDate == today) return 'Today';
      if (entryDate == yesterday) return 'Yesterday';
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _columnWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
              bottom: AppTheme.spacing12,
            ),
            child: Text(
              _formatDate(date),
              style: AppTheme.heading2.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: ClipRect(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: dreams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacing10),
                  itemBuilder: (context, i) => _DreamItem(dream: dreams[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DreamItem extends StatelessWidget {
  const _DreamItem({required this.dream});

  final JournalEntryRecord dream;

  @override
  Widget build(BuildContext context) {
    final content = dream.content;
    final time = dream.time;
    final preview = content.length > 150 ? '${content.substring(0, 150)}...' : content;

    return AppCard(
      boxShadow: const [],
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dream', style: AppTheme.caption.copyWith(color: AppTheme.textTertiary)),
                if (time != null)
                  Text(
                    _formatTime(time),
                    style: AppTheme.caption.copyWith(color: AppTheme.textTertiary, fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              preview,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return timeStr;
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final ampm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:$minute $ampm';
    } catch (_) {
      return timeStr;
    }
  }
}
