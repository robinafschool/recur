import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../models/models.dart';

class AnalyticsScreen extends StatefulWidget {
  final bool showNavBar;

  const AnalyticsScreen({super.key, this.showNavBar = true});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedFilter = 0;

  void _navigateToScreen(int index) {
    AppNavigator.navigateToIndex(context, NavIndex.analytics, index);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: widget.showNavBar
          ? BottomNavBar(
              currentIndex: NavIndex.analytics,
              onTap: _navigateToScreen,
            )
          : null,
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
    return AppCard(
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.heading2),
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Streaks', style: AppTheme.heading2),
          const SizedBox(height: AppTheme.spacing15),
          ...streaks.asMap().entries.map((entry) {
            final isLast = entry.key == streaks.length - 1;
            return LabeledListItem(
              label: entry.value.name,
              trailing: Text('${entry.value.days} days', style: AppTheme.body),
              showBottomBorder: !isLast,
            );
          }),
        ],
      ),
    );
  }
}
