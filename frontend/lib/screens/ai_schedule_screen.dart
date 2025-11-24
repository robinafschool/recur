import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/gradient_header.dart';
import '../utils/route_generator.dart';
import 'analytics_screen.dart';
import 'journal_list_screen.dart';
import 'journal_entry_screen.dart';
import 'settings_screen.dart';

class AiScheduleScreen extends StatefulWidget {
  final bool showNavBar;
  
  const AiScheduleScreen({super.key, this.showNavBar = true});

  @override
  State<AiScheduleScreen> createState() => _AiScheduleScreenState();
}

class _AiScheduleScreenState extends State<AiScheduleScreen> {
  static const int _currentIndex = 3; // Schedule is fourth item

  void _navigateToScreen(int index) {
    if (index == _currentIndex) return; // Don't navigate if already on this screen

    final routes = ['/analytics', '/journal-list', '/journal-entry', '/ai-schedule', '/settings'];
    final direction = getSlideDirection(_currentIndex, index);
    
    Navigator.pushReplacement(
      context,
      SlideRoute(
        page: _getRouteWidget(routes[index]),
        direction: direction,
      ),
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
        return const AiScheduleScreen();
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
                icon: Icons.schedule,
                title: 'Schedule & Habits',
                description:
                    'Habits are automatically created from your journal entries. AI suggestions help you stay on track with your goals.',
              ),
              const SizedBox(height: AppTheme.spacing30),
              _buildAiInfo(),
              const SizedBox(height: AppTheme.spacing20),
              _buildScheduledActions(),
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

  Widget _buildAiInfo() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
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
              'Habits are automatically created from your journal entries. AI suggestions help you stay on track with your goals.',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledActions() {
    final actions = [
      ScheduledAction(
        time: '9:00 AM',
        type: 'Habit',
        content: 'Morning exercise routine',
        reason: 'Created from: "Starting morning workouts daily" (Dec 8)',
      ),
      ScheduledAction(
        time: '2:00 PM',
        type: 'Suggestion',
        content: 'Take a 15-minute break and reflect on your progress',
        reason:
            'Based on: Your recent entries show high stress levels in the afternoon',
      ),
      ScheduledAction(
        time: '7:00 PM',
        type: 'Habit',
        content: 'Write journal entry',
        reason: 'Created from: "I want to journal every evening" (Dec 10)',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Tasks',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.spacing15),
          ...actions.map((action) => _buildActionItem(action)),
        ],
      ),
    );
  }

  Widget _buildActionItem(ScheduledAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing15),
      padding: const EdgeInsets.all(AppTheme.spacing15),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                action.time,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing12,
                  vertical: AppTheme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: action.type == 'Habit'
                      ? AppTheme.primaryColor.withOpacity(0.2)
                      : AppTheme.successColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                ),
                child: Text(
                  action.type,
                  style: AppTheme.caption.copyWith(
                    color: action.type == 'Habit'
                        ? AppTheme.primaryColor
                        : AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing10),
          Text(
            action.content,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacing10),
          Container(
            padding: const EdgeInsets.only(top: AppTheme.spacing10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.dividerColor,
                  width: AppTheme.borderWidthThin,
                ),
              ),
            ),
            child: Text(
              action.reason,
              style: TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing8,
                    ),
                  ),
                  child: Text(
                    action.type == 'Habit' ? 'Skip' : 'Dismiss',
                    style: const TextStyle(fontSize: AppTheme.fontSizeSmall),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing8,
                    ),
                  ),
                  child: Text(
                    action.type == 'Habit' ? 'Complete' : 'Accept',
                    style: const TextStyle(fontSize: AppTheme.fontSizeSmall),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ScheduledAction {
  final String time;
  final String type;
  final String content;
  final String reason;

  ScheduledAction({
    required this.time,
    required this.type,
    required this.content,
    required this.reason,
  });
}

