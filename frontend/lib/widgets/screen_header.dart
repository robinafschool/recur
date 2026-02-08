import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Reusable screen header with title and optional action button
class ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSettingsTap;
  final bool showSettingsButton;

  const ScreenHeader({
    super.key,
    required this.title,
    this.onSettingsTap,
    this.showSettingsButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTheme.heading1),
        if (showSettingsButton)
          GestureDetector(
            onTap:
                onSettingsTap ??
                () => Navigator.pushNamed(context, '/settings'),
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
}
