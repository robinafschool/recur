import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';

class JournalListScreen extends StatefulWidget {
  final bool showNavBar;

  const JournalListScreen({super.key, this.showNavBar = true});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  List<Map<String, dynamic>> _dreams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('journal_entries')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      setState(() {
        _dreams = (response as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dreams: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToScreen(int index) {
    AppNavigator.navigateToIndex(context, NavIndex.journalList, index);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final entryDate = DateTime(date.year, date.month, date.day);

      if (entryDate == today) {
        return 'Today';
      } else if (entryDate == yesterday) {
        return 'Yesterday';
      } else {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return timeStr;
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final ampm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:$minute $ampm';
    } catch (e) {
      return timeStr;
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupDreamsByDate() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final dream in _dreams) {
      final date = dream['date'] as String? ?? '';
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(dream);
    }
    return grouped;
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
      child: RefreshIndicator(
        onRefresh: _loadDreams,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GradientHeader(
                icon: Icons.book_outlined,
                title: 'Dream Journal',
                description:
                    'Review your dreams and track patterns over time.',
              ),
              const SizedBox(height: AppTheme.spacing30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDreamsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDreamsList() {
    final groupedDreams = _groupDreamsByDate();

    if (groupedDreams.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing60),
        child: Column(
          children: [
            Icon(Icons.nightlight_round, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: AppTheme.spacing20),
            Text(
              'No dreams recorded yet',
              style: AppTheme.bodySecondary,
            ),
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

    return Column(
      children: groupedDreams.entries.map((entry) {
        final date = entry.key;
        final dreams = entry.value;
        return _buildDateGroup(date, dreams);
      }).toList(),
    );
  }

  Widget _buildDateGroup(String date, List<Map<String, dynamic>> dreams) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacing10,
            bottom: AppTheme.spacing10,
            top: AppTheme.spacing10,
          ),
          child: Text(
            _formatDate(date),
            style: AppTheme.heading2,
          ),
        ),
        ...dreams.map((dream) => _buildDreamItem(dream)),
        const SizedBox(height: AppTheme.spacing10),
      ],
    );
  }

  Widget _buildDreamItem(Map<String, dynamic> dream) {
    final content = dream['content'] as String? ?? '';
    final time = dream['time'] as String?;
    final preview = content.length > 150 ? '${content.substring(0, 150)}...' : content;

    return GestureDetector(
      onTap: () {
        // Could navigate to a detail view in the future
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing15),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dream',
                    style: AppTheme.bodySecondary,
                  ),
                  if (time != null)
                    Text(
                      _formatTime(time),
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing10),
              Text(
                preview,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
