import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Reusable gradient header widget with icon, title, and description
class GradientHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const GradientHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppTheme.spacing30),
        Icon(icon, size: 35, color: Colors.white),
        const SizedBox(height: AppTheme.spacing20),
        Text(
          title,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeDisplay,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacing12),
        Text(
          description,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeMedium,
            color: Colors.white,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

