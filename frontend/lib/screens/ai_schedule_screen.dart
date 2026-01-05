import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';

class AiScheduleScreen extends StatefulWidget {
  final bool showNavBar;

  const AiScheduleScreen({super.key, this.showNavBar = true});

  @override
  State<AiScheduleScreen> createState() => _AiScheduleScreenState();
}

class _AiScheduleScreenState extends State<AiScheduleScreen> {
  List<Map<String, String>> _eventSuggestions = [];
  bool _isLoadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadEventSuggestions();
  }

  Future<void> _loadEventSuggestions() async {
    setState(() => _isLoadingSuggestions = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Get recent dreams
      final dreamsResponse = await Supabase.instance.client
          .from('journal_entries')
          .select('content')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(20);

      if (dreamsResponse.isEmpty) {
        setState(() {
          _eventSuggestions = [];
          _isLoadingSuggestions = false;
        });
        return;
      }

      // Simple extraction of common entities (in production, use AI/LLM)
      final allContent = (dreamsResponse as List)
          .map((e) => e['content'] as String? ?? '')
          .join(' ')
          .toLowerCase();

      // Extract potential triggers (simple keyword matching)
      final suggestions = <Map<String, String>>[];
      final commonPatterns = [
        {'word': 'pet', 'trigger': 'when you see your pet'},
        {'word': 'dog', 'trigger': 'when you see a dog'},
        {'word': 'cat', 'trigger': 'when you see a cat'},
        {'word': 'friend', 'trigger': 'when you see a friend'},
        {'word': 'school', 'trigger': 'when you see your school'},
        {'word': 'office', 'trigger': 'when you see your office'},
        {'word': 'work', 'trigger': 'when you see your workplace'},
        {'word': 'home', 'trigger': 'when you see your home'},
        {'word': 'car', 'trigger': 'when you see a car'},
        {'word': 'phone', 'trigger': 'when you see your phone'},
      ];

      for (final pattern in commonPatterns) {
        if (allContent.contains(pattern['word']!)) {
          suggestions.add({
            'trigger': pattern['trigger']!,
            'reason': 'Based on: Your recent dreams frequently mention ${pattern['word']}',
          });
        }
      }

      setState(() {
        _eventSuggestions = suggestions.take(5).toList();
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      debugPrint('Error loading event suggestions: $e');
      setState(() => _isLoadingSuggestions = false);
    }
  }

  void _navigateToScreen(int index) {
    AppNavigator.navigateToIndex(context, NavIndex.aiSchedule, index);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: widget.showNavBar
          ? BottomNavBar(
              currentIndex: NavIndex.aiSchedule,
              onTap: _navigateToScreen,
            )
          : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GradientHeader(
              icon: Icons.auto_awesome,
              title: 'AI Dream Insights',
              description:
                  'AI analyzes your dreams to suggest reality check triggers that can help you achieve lucid dreams.',
            ),
            const SizedBox(height: AppTheme.spacing30),
            _buildAiInfo(),
            const SizedBox(height: AppTheme.spacing20),
            _buildEventSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAiInfo() {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing15),
          const Expanded(
            child: Text(
              'AI analyzes your dream patterns to suggest personalized reality check triggers. These help you recognize when you\'re dreaming.',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSuggestions() {
    if (_isLoadingSuggestions) {
      return const AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacing30),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_eventSuggestions.isEmpty) {
      return AppCard(
        child: Column(
          children: [
            Icon(Icons.nightlight_round, size: 48, color: AppTheme.textTertiary),
            const SizedBox(height: AppTheme.spacing15),
            Text(
              'No suggestions yet',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: AppTheme.spacing10),
            Text(
              'Record more dreams to get personalized reality check suggestions',
              style: AppTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Suggested Reality Check Triggers", style: AppTheme.heading2),
              TextButton.icon(
                onPressed: _loadEventSuggestions,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing15),
          ..._eventSuggestions.map((suggestion) => _buildSuggestionItem(suggestion)),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, String> suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing15),
      padding: const EdgeInsets.all(AppTheme.spacing15),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacing8),
              Expanded(
                child: Text(
                  suggestion['trigger']!,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing10),
          Text(
            suggestion['reason']!,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeSmall,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppTheme.spacing10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.habits,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacing8,
              ),
            ),
            child: const Text('Create Reality Check'),
          ),
        ],
      ),
    );
  }
}
