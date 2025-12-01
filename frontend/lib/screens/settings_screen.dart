import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../models/models.dart';

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

  void _navigateToScreen(int index) {
    AppNavigator.navigateToIndex(context, NavIndex.settings, index);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: widget.showNavBar
          ? BottomNavBar(
              currentIndex: NavIndex.settings,
              onTap: _navigateToScreen,
            )
          : null,
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
    );
  }

  Widget _buildAccountInfo() {
    final user = Supabase.instance.client.auth.currentUser;

    // Get user's email
    final email = user?.email ?? 'Not signed in';

    // Get user's name from metadata or email
    String displayName = 'User';
    String initials = 'U';

    if (user != null) {
      // Try to get name from user metadata
      final metadata = user.userMetadata;
      if (metadata != null) {
        displayName =
            metadata['full_name'] as String? ??
            metadata['name'] as String? ??
            email.split('@').first;
      } else {
        displayName = email.split('@').first;
      }

      // Generate initials from display name
      final nameParts = displayName.split(' ');
      if (nameParts.length >= 2) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (displayName.isNotEmpty) {
        initials = displayName.substring(0, 1).toUpperCase();
      }
    }

    return AppCard(
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
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeHuge,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeXLarge,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(email, style: AppTheme.bodySecondary),
                if (user != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'User ID: ${user.id.substring(0, 8)}...',
                    style: AppTheme.caption,
                  ),
                ],
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
          trailing: ToggleSwitch(
            value: _habitReminders,
            onChanged: (value) => setState(() => _habitReminders = value),
          ),
        ),
        SettingItem(
          label: 'Journal Prompts',
          trailing: ToggleSwitch(
            value: _journalPrompts,
            onChanged: (value) => setState(() => _journalPrompts = value),
          ),
        ),
        SettingItem(
          label: 'AI Suggestions',
          trailing: ToggleSwitch(
            value: _aiSuggestions,
            onChanged: (value) => setState(() => _aiSuggestions = value),
          ),
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.heading2),
          const SizedBox(height: AppTheme.spacing20),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return LabeledListItem(
              label: item.label,
              trailing: item.trailing,
              showBottomBorder: !isLast,
              onTap: item.onTap,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton(
      onPressed: () async {
        // Show confirmation dialog
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        );

        if (shouldLogout == true && mounted) {
          try {
            await Supabase.instance.client.auth.signOut();
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error signing out: ${e.toString()}'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        }
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
