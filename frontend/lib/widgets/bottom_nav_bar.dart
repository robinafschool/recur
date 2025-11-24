import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
            width: AppTheme.borderWidthMedium,
          ),
        ),
        color: AppTheme.backgroundColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing15,
        horizontal: AppTheme.spacing10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'journ'),
          _buildNavItem(1, 'j entry'),
          _buildNavItem(2, 'sched'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label) {
    final isActive = index == currentIndex;

    if (isActive) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.activeGreen,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.activeGreen,
              width: AppTheme.borderWidthMedium,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.fontSizeSmall,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing20,
          vertical: AppTheme.spacing10,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: AppTheme.borderColor,
            width: AppTheme.borderWidthMedium,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: AppTheme.fontSizeSmall,
          ),
        ),
      ),
    );
  }
}

