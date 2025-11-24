import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _habitReminders = true;
  bool _journalPrompts = true;
  bool _aiSuggestions = false;

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
          'Settings',
          style: AppTheme.heading1,
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.borderColor,
                width: AppTheme.borderWidthMedium,
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfo() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.borderColor,
          width: AppTheme.borderWidthMedium,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.borderColor,
                width: AppTheme.borderWidthMedium,
              ),
              color: AppTheme.surfaceColor,
            ),
            child: const Center(
              child: Text(
                'JD',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeHuge,
                  color: AppTheme.textPrimary,
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
                Text(
                  'john.doe@example.com',
                  style: AppTheme.bodySecondary,
                ),
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
          trailing: const Text(
            'Dark',
            style: AppTheme.bodySecondary,
          ),
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
          trailing: const Text(
            '1.0.0',
            style: AppTheme.bodySecondary,
          ),
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
                      color: isLast ? Colors.transparent : AppTheme.dividerColor,
                      width: AppTheme.borderWidthThin,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: AppTheme.body,
                    ),
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

  SettingItem({
    required this.label,
    required this.trailing,
    this.onTap,
  });
}

