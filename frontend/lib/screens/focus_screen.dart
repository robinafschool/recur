import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

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
          'Focus Mode',
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

  Widget _buildTimerDisplay() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.borderColor,
          width: AppTheme.borderWidthMedium,
        ),
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
          Text(
            'Focus Session',
            style: AppTheme.heading2,
          ),
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
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : AppTheme.borderColor,
            width: AppTheme.borderWidthMedium,
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.textPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBlockedApps() {
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
            'Blocked Apps',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.spacing15),
          ..._apps.map((app) => _buildAppItem(app)),
        ],
      ),
    );
  }

  Widget _buildAppItem(BlockedApp app) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            app.name,
            style: AppTheme.body,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                app.isBlocked = !app.isBlocked;
              });
            },
            child: _buildToggleSwitch(app.isBlocked),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch(bool isActive) {
    return Container(
      width: 50,
      height: 26,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.transparent,
        border: Border.all(
          color: isActive ? AppTheme.primaryColor : AppTheme.borderColor,
          width: AppTheme.borderWidthMedium,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Align(
        alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(3),
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: AppTheme.textPrimary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildFocusSessions() {
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
            'Today\'s Sessions',
            style: AppTheme.heading2,
          ),
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
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        label,
        style: AppTheme.bodySecondary,
      ),
    );
  }
}

class BlockedApp {
  String name;
  bool isBlocked;

  BlockedApp({required this.name, required this.isBlocked});
}

