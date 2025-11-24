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
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing15,
        horizontal: AppTheme.spacing10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, '', Icons.insights),
          _buildNavItem(1, '', Icons.book_outlined),
          _buildNavItem(2, '', Icons.edit),
          _buildNavItem(3, '', Icons.schedule),
          _buildNavItem(4, '', Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isActive = index == currentIndex;
    final isJournalEntry = index == 2; // Journal Entry is always special

    // Journal Entry button - always larger circle that pops out
    if (isJournalEntry) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
            boxShadow: AppTheme.buttonShadow,
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      );
    }

    // Other buttons - icon only, darker when active
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(AppTheme.spacing12),
        child: Icon(
          icon,
          color: isActive
              ? AppTheme.primaryColor
              : AppTheme.textSecondary.withOpacity(0.6),
          size: 24,
        ),
      ),
    );
  }
}

