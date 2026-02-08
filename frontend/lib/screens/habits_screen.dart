import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../models/models.dart';

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
    AppNavigator.navigateToIndex(context, NavIndex.journalList, index);
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
              ScreenHeader(
                title: 'welcome back <name>',
                onSettingsTap: () =>
                    Navigator.pushNamed(context, AppRoutes.settings),
              ),
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
        currentIndex: NavIndex.journalList,
        onTap: _navigateToScreen,
      ),
    );
  }

  Widget _buildHabitsChecklist() {
    return AppCard(
      constraints: const BoxConstraints(minHeight: 400),
      child: Column(
        children: _habits
            .map(
              (habit) => CheckboxItem(
                isChecked: habit.isCompleted,
                label: habit.name,
                onChanged: (value) {
                  setState(() => habit.isCompleted = value);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCreationDetails() {
    return const AppCard(
      child: Column(
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
