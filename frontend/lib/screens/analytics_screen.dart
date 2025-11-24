import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedFilter = 0;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
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
            BottomNavBar(
              currentIndex: -1,
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
          'Analytics & Trends',
          style: AppTheme.heading1,
        ),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                  vertical: AppTheme.spacing10,
                ),
              ),
              child: const Text(
                '← Back',
                style: TextStyle(fontSize: AppTheme.fontSizeMedium),
              ),
            ),
            const SizedBox(width: AppTheme.spacing10),
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
        ),
      ],
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
          vertical: AppTheme.spacing10,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : AppTheme.borderColor,
            width: AppTheme.borderWidthMedium,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeMedium,
            color: AppTheme.textPrimary,
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
        border: Border.all(
          color: AppTheme.borderColor,
          width: AppTheme.borderWidthMedium,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
          Text(
            title,
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.spacing15),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF444444),
                width: AppTheme.borderWidthThin,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Center(
              child: Text(
                'Chart visualization',
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

