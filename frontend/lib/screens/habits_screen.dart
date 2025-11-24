import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final List<HabitItem> _habits = [
    HabitItem(name: 'Morning Exercise', isCompleted: false),
    HabitItem(name: 'Read 30 minutes', isCompleted: false),
    HabitItem(name: 'Meditation', isCompleted: false),
  ];

  void _navigateToScreen(int index) {
    final routes = ['/journal-list', '/journal-entry', '/ai-schedule'];
    Navigator.pushReplacementNamed(context, routes[index]);
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
                    _buildHabitsChecklist(),
                    const SizedBox(height: AppTheme.spacing20),
                    OutlinedButton(
                      onPressed: () {
                        // Show create habit dialog
                      },
                      child: const Text('create new habit btn'),
                    ),
                    const SizedBox(height: AppTheme.spacing20),
                    _buildCreationDetails(),
                  ],
                ),
              ),
            ),
            BottomNavBar(
              currentIndex: -1, // No active item on habits screen
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
          'welcome back <name>',
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

  Widget _buildHabitsChecklist() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.borderColor,
          width: AppTheme.borderWidthMedium,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      constraints: const BoxConstraints(minHeight: 400),
      child: Column(
        children: _habits
            .map((habit) => _buildHabitItem(habit))
            .toList(),
      ),
    );
  }

  Widget _buildHabitItem(HabitItem habit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor,
            width: AppTheme.borderWidthThin,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                habit.isCompleted = !habit.isCompleted;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: AppTheme.borderWidthMedium,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                color: habit.isCompleted
                    ? AppTheme.primaryColor
                    : Colors.transparent,
              ),
              child: habit.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppTheme.textPrimary,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppTheme.spacing15),
          Expanded(
            child: Text(
              habit.name,
              style: AppTheme.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreationDetails() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.borderColor,
          width: AppTheme.borderWidthMedium,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'creation details (popup after click ^^)',
            style: AppTheme.caption,
          ),
          SizedBox(height: AppTheme.spacing10),
          Text(
            'very detailed: days per week, days per month, every day, every x days, all shown in a compact way',
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }
}

class HabitItem {
  String name;
  bool isCompleted;

  HabitItem({required this.name, required this.isCompleted});
}

