import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Reusable toggle switch widget with animation
class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Container(
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          color: value ? AppTheme.primaryColor : AppTheme.borderColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
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
}

