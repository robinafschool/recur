import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/route_generator.dart';
import '../widgets/gradient_header.dart';
import 'analytics_screen.dart';
import 'journal_list_screen.dart';
import 'journal_entry_screen.dart';
import 'ai_schedule_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool showNavBar;

  const SettingsScreen({super.key, this.showNavBar = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _habitReminders = true;
  bool _journalPrompts = true;
  bool _aiSuggestions = false;
  static const int _currentIndex = 4; // Settings is rightmost item

  void _navigateToScreen(int index) {
    if (index == _currentIndex)
      return; // Don't navigate if already on this screen

    final routes = [
      '/analytics',
      '/journal-list',
      '/journal-entry',
      '/ai-schedule',
      '/settings',
    ];
    final direction = getSlideDirection(_currentIndex, index);

    Navigator.pushReplacement(
      context,
      SlideRoute(page: _getRouteWidget(routes[index]), direction: direction),
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
        return const SettingsScreen();
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
                icon: Icons.settings_outlined,
                title: 'Settings',
                description:
                    'Manage your account, preferences, and app settings.',
              ),
              const SizedBox(height: AppTheme.spacing30),
              _buildAccountInfo(),
              const SizedBox(height: AppTheme.spacing20),
              _buildNotificationSettings(),
              const SizedBox(height: AppTheme.spacing20),
              _buildPrivacySettings(),
              const SizedBox(height: AppTheme.spacing20),
              _buildAppearanceSettings(),
              const SizedBox(height: AppTheme.spacing20),
              _buildAboutSettings(),
              const SizedBox(height: AppTheme.spacing20),
              _buildLogoutButton(),
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

  Widget _buildAccountInfo() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'JD',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeHuge,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeXLarge,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 5),
                Text('john.doe@example.com', style: AppTheme.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(
      title: 'Notifications',
      items: [
        SettingItem(
          label: 'Habit Reminders',
          trailing: _buildToggleSwitch(_habitReminders, (value) {
            setState(() {
              _habitReminders = value;
            });
          }),
        ),
        SettingItem(
          label: 'Journal Prompts',
          trailing: _buildToggleSwitch(_journalPrompts, (value) {
            setState(() {
              _journalPrompts = value;
            });
          }),
        ),
        SettingItem(
          label: 'AI Suggestions',
          trailing: _buildToggleSwitch(_aiSuggestions, (value) {
            setState(() {
              _aiSuggestions = value;
            });
          }),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSettingsSection(
      title: 'Privacy',
      items: [
        SettingItem(
          label: 'Data Export',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.textSecondary,
            size: 16,
          ),
          onTap: () {},
        ),
        SettingItem(
          label: 'Delete Account',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.textSecondary,
            size: 16,
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings() {
    return _buildSettingsSection(
      title: 'Appearance',
      items: [
        SettingItem(
          label: 'Theme',
          trailing: const Text('Dark', style: AppTheme.bodySecondary),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAboutSettings() {
    return _buildSettingsSection(
      title: 'About',
      items: [
        SettingItem(
          label: 'Version',
          trailing: const Text('1.0.0', style: AppTheme.bodySecondary),
        ),
        SettingItem(
          label: 'Terms of Service',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.textSecondary,
            size: 16,
          ),
          onTap: () {},
        ),
        SettingItem(
          label: 'Privacy Policy',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.textSecondary,
            size: 16,
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<SettingItem> items,
  }) {
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
          Text(title, style: AppTheme.heading2),
          const SizedBox(height: AppTheme.spacing20),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return GestureDetector(
              onTap: item.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacing15,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isLast
                          ? Colors.transparent
                          : AppTheme.dividerColor,
                      width: AppTheme.borderWidthThin,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label, style: AppTheme.body),
                    item.trailing,
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch(bool isActive, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isActive),
      child: Container(
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : AppTheme.borderColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.softShadow,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton(
      onPressed: () {
        // Handle logout
        Navigator.pushReplacementNamed(context, '/login');
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: AppTheme.errorColor,
          width: AppTheme.borderWidthMedium,
        ),
        foregroundColor: AppTheme.errorColor,
      ),
      child: const Text('Sign Out'),
    );
  }
}

class SettingItem {
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  SettingItem({required this.label, required this.trailing, this.onTap});
}
