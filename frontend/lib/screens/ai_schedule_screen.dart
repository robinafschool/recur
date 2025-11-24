import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../models/models.dart';

class AiScheduleScreen extends StatefulWidget {
  final bool showNavBar;

  const AiScheduleScreen({super.key, this.showNavBar = true});

  @override
  State<AiScheduleScreen> createState() => _AiScheduleScreenState();
}

class _AiScheduleScreenState extends State<AiScheduleScreen> {
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
              'Habits are automatically created from your journal entries. AI suggestions help you stay on track with your goals.',
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Tasks", style: AppTheme.heading2),
          const SizedBox(height: AppTheme.spacing15),
          ...actions.map((action) => _buildActionItem(action)),
        ],
      ),
    );
  }

  Widget _buildActionItem(ScheduledAction action) {
    final isHabit = action.type == 'Habit';

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
              TagChip(
                label: action.type,
                backgroundColor: isHabit
                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                    : AppTheme.successColor.withValues(alpha: 0.2),
                textColor: isHabit ? AppTheme.primaryColor : AppTheme.successColor,
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
              style: const TextStyle(
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
                    isHabit ? 'Skip' : 'Dismiss',
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
                    isHabit ? 'Complete' : 'Accept',
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
