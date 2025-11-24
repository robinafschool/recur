import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../models/models.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  bool _isPlaying = true;
  final List<BlockedApp> _apps = [
    BlockedApp(name: 'Social Media', isBlocked: true),
    BlockedApp(name: 'Games', isBlocked: true),
    BlockedApp(name: 'News', isBlocked: false),
  ];

  void _navigateToScreen(int index) {
    AppNavigator.navigateToIndex(context, NavIndex.journalList, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: 'Focus Mode',
                onSettingsTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
              const SizedBox(height: AppTheme.spacing40),
              _buildTimerDisplay(),
              const SizedBox(height: AppTheme.spacing30),
              _buildTimerControls(),
              const SizedBox(height: AppTheme.spacing30),
              _buildBlockedApps(),
              const SizedBox(height: AppTheme.spacing20),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Manage Blocked Apps'),
              ),
              const SizedBox(height: AppTheme.spacing20),
              _buildFocusSessions(),
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

  Widget _buildTimerDisplay() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.cardShadow,
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '25:00',
            style: TextStyle(
              fontSize: AppTheme.fontSizeTimer,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.spacing10),
          Text('Focus Session', style: AppTheme.heading2),
        ],
      ),
    );
  }

  Widget _buildTimerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimerButton(Icons.pause, false),
        const SizedBox(width: AppTheme.spacing20),
        _buildTimerButton(Icons.play_arrow, _isPlaying),
        const SizedBox(width: AppTheme.spacing20),
        _buildTimerButton(Icons.stop, false),
      ],
    );
  }

  Widget _buildTimerButton(IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPlaying = icon == Icons.play_arrow;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppTheme.primaryColor : AppTheme.surfaceColor,
          boxShadow: isActive ? AppTheme.buttonShadow : AppTheme.softShadow,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppTheme.textSecondary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildBlockedApps() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Blocked Apps', style: AppTheme.heading2),
          const SizedBox(height: AppTheme.spacing15),
          ..._apps.map((app) => LabeledListItem(
                label: app.name,
                trailing: ToggleSwitch(
                  value: app.isBlocked,
                  onChanged: (value) {
                    setState(() => app.isBlocked = value);
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFocusSessions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Sessions", style: AppTheme.heading2),
          const SizedBox(height: AppTheme.spacing15),
          _buildSessionItem('Morning Focus - 25 min'),
          const SizedBox(height: AppTheme.spacing10),
          _buildSessionItem('Afternoon Deep Work - 50 min'),
        ],
      ),
    );
  }

  Widget _buildSessionItem(String label) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing15),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(label, style: AppTheme.body),
          ),
        ],
      ),
    );
  }
}
