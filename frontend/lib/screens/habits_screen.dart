import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/route_generator.dart';
import 'analytics_screen.dart';
import 'journal_list_screen.dart';
import 'journal_entry_screen.dart';
import 'ai_schedule_screen.dart';
import 'settings_screen.dart';

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
    final routes = ['/analytics', '/journal-list', '/journal-entry', '/ai-schedule', '/settings'];
    final direction = getSlideDirection(1, index); // Habits is like being on journal list
    
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
        return const JournalListScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppTheme.spacing30),
              Expanded(child: _buildHabitsChecklist()),
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1, // Journal is middle item
        onTap: _navigateToScreen,
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
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: AppTheme.softShadow,
            ),
            child: const Center(
              child: Icon(
                Icons.settings_outlined,
                color: AppTheme.primaryColor,
                size: 24,
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
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
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
                borderRadius: BorderRadius.circular(6),
                color: habit.isCompleted
                    ? AppTheme.primaryColor
                    : AppTheme.backgroundColor,
                border: Border.all(
                  color: habit.isCompleted
                      ? AppTheme.primaryColor
                      : AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: habit.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
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
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
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

