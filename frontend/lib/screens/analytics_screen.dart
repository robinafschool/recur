import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/route_generator.dart';
import '../widgets/gradient_header.dart';
import 'journal_list_screen.dart';
import 'journal_entry_screen.dart';
import 'ai_schedule_screen.dart';
import 'settings_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  final bool showNavBar;
  
  const AnalyticsScreen({super.key, this.showNavBar = true});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedFilter = 0;
  static const int _currentIndex = 0; // Insights is left item

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
        return const AnalyticsScreen();
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
                icon: Icons.insights,
                title: 'Analytics & Trends',
                description:
                    'Track your progress, view statistics, and analyze your habits over time.',
              ),
              const SizedBox(height: AppTheme.spacing30),
              _buildFilterBar(),
              const SizedBox(height: AppTheme.spacing20),
              _buildStatsGrid(),
              const SizedBox(height: AppTheme.spacing20),
              _buildChartBox('Habit Progress'),
              const SizedBox(height: AppTheme.spacing20),
              _buildChartBox('Journal Entries Over Time'),
              const SizedBox(height: AppTheme.spacing20),
              _buildStreakBox(),
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

  Widget _buildFilterBar() {
    final filters = ['All Time', 'This Month', 'This Week', 'Custom'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .asMap()
            .entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacing10),
                  child: _buildFilterButton(entry.key, entry.value),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFilterButton(int index, String label) {
    final isActive = index == _selectedFilter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing20,
          vertical: AppTheme.spacing12,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
          boxShadow: isActive ? AppTheme.buttonShadow : AppTheme.softShadow,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.fontSizeMedium,
            color: isActive ? Colors.white : AppTheme.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('42', 'Day Streak')),
        const SizedBox(width: AppTheme.spacing15),
        Expanded(child: _buildStatCard('87%', 'Completion Rate')),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeDisplay,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: AppTheme.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartBox(String title) {
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
          Text(
            title,
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.spacing15),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Center(
              child: Text(
                '📊 Chart visualization',
                style: AppTheme.bodySecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBox() {
    final streaks = [
      StreakItem(name: 'Morning Exercise', days: 15),
      StreakItem(name: 'Reading', days: 8),
      StreakItem(name: 'Meditation', days: 23),
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
            'Current Streaks',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.spacing15),
          ...streaks.map((streak) => Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacing10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.dividerColor,
                      width: AppTheme.borderWidthThin,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      streak.name,
                      style: AppTheme.body,
                    ),
                    Text(
                      '${streak.days} days',
                      style: AppTheme.body,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class StreakItem {
  final String name;
  final int days;

  StreakItem({required this.name, required this.days});
}

