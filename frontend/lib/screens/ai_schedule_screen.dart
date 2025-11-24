import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class AiScheduleScreen extends StatefulWidget {
  const AiScheduleScreen({super.key});

  @override
  State<AiScheduleScreen> createState() => _AiScheduleScreenState();
}

class _AiScheduleScreenState extends State<AiScheduleScreen> {
  void _navigateToScreen(int index) {
    final routes = ['/journal-list', '/journal-entry', '/ai-schedule'];
    if (index != 2) {
      // Don't navigate if already on ai-schedule
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppTheme.spacing30),
                    _buildAiInfo(),
                    const SizedBox(height: AppTheme.spacing20),
                    _buildScheduledActions(),
                  ],
                ),
              ),
            ),
            BottomNavBar(
              currentIndex: 2,
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
          'Schedule & Habits',
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

  Widget _buildAiInfo() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.borderColor,
          width: AppTheme.borderWidthMedium,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        color: AppTheme.surfaceColor,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: const Text(
        'Habits are automatically created from your journal entries. AI suggestions help you stay on track with your goals.',
        style: TextStyle(
          fontSize: AppTheme.fontSizeMedium,
          color: Color(0xFFCCCCCC),
          height: 1.6,
        ),
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
        border: Border.all(
          color: AppTheme.borderColor,
          width: AppTheme.borderWidthMedium,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
        border: Border.all(
          color: const Color(0xFF444444),
          width: AppTheme.borderWidthMedium,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        color: AppTheme.surfaceColor,
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
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  action.type,
                  style: AppTheme.caption,
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

